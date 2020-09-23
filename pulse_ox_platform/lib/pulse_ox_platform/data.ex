defmodule PulseOxPlatform.Data do
  @moduledoc """
  Pulls the pulse oximeter data from the storage mechanism into a CSV file in order
  for other things and people to perform further analysis on it. Like easily sharing the
  data with doctors.
  """

  import Ecto.Query

  alias PulseOxPlatform.Repo

  def setup_ets do
    :ets.new(:po_data, [:named_table, :set, :public, read_concurrency: true])
    :ets.insert(:po_data, {:event, :init})
  end

  @doc "Starts a gather read loop to insert data"
  def data_gather_loop do
    case PulseOxReader.next(:reader) do
      %PulseOxReader{} = por ->
        :ets.insert(:po_data, {:event, por})
        data_gather_loop()

      _ ->
        PulseOxReader.reconnect(:reader)
        :ets.insert(:po_data, {:event, :disconnected})
        data_gather_loop()
    end
  end

  @doc """
  Query the pulse oximeter data store in order to get statisticus about blood oxygen levels
  including the durration of the data and the cutoff values for the minimum datetime and
  perfusion index ranges as well as maximum spo2 range.

  The cutoff on the perfusion index is there to prevent bad readings from entering the average.
  Unfortunately, the `Signal Quality` or `SIQ` numbers from the RAD8 and other pulse oximeters
  is not readable through the standard serial output. One day, perhaps the Philips IntelliVue
  output will be entirely decoded and open so that we can have nicer graphs and charts.

  Note: Each database entry is calculated based on each datapoint take half a second long.
  """
  @spec analyze_spo2(DateTime.t(), number()) :: tuple()
  def analyze_spo2(dt \\ DateTime.utc_now(), spo2_level \\ 100) do
    qry =
      from(
        e in PulseOx.Schema.Event,
        where: e.perfusion_index > 0.15,
        where: e.spo2 <= ^spo2_level,
        where: e.inserted_at > ^dt
      )

    average = Repo.aggregate(qry, :avg, :spo2)
    count = Repo.aggregate(qry, :count, :spo2)
    avg_durration = calculate_time(count)
    {average, avg_durration}
  end

  defp calculate_time(count) do
    seconds = Enum.reduce(1..count, 0, fn _, acc -> 0.5 + acc end)
    minutes = seconds / 60.0

    if minutes > 60.0 do
      {:hrs, minutes / 60.0}
    else
      {:mins, minutes}
    end
  end
end