defmodule PulseOxPlatform.Data do
  @moduledoc """
  Pulls the pulse oximeter data from the mNEsia database into a CSV file in order
  for other things and people to perform further analysis on it. Like easily sharing the
  data with doctors.
  """

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
end
