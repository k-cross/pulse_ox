defmodule PulseOxPlatform.Data do
  @moduledoc """
  Pulls the pulse oximeter data from the storage mechanism into a CSV file in
  order for other things and people to perform further analysis on it. Like
  easily sharing the data with doctors.
  """

  import Ecto.Query

  alias Contex.{LinePlot, PointPlot, Plot}
  alias PulseOxPlatform.Repo

  # 5 minutes worth of data
  @live_samples 300
  @y_cols ["SPO2", "BPM", "Perf. Index"]

  def setup_ets do
    :ets.new(:po_data, [:named_table, :set, :public, read_concurrency: true])
    :ets.insert(:po_data, {:event, :init})
    :ets.insert(:po_data, {:graph, []})
  end

  @doc """
  Starts a read loop against the pulse oximeter to insert data into two areas:
  * live updated data that displays numerical information
  * historical graphs of the last 5 minutes
  """
  def data_gather_loop do
    case PulseOxReader.next(:reader) do
      %PulseOxReader{} = por ->
        :ets.insert(:po_data, {:event, por})
        :ets.insert(:po_data, {:graph, add_data(por, :ets.lookup(:po_data, :graph))})
        data_gather_loop()

      _ ->
        PulseOxReader.reconnect(:reader)
        :ets.insert(:po_data, {:event, :disconnected})
        :ets.insert(:po_data, {:graph, add_data(:disconnected, :ets.lookup(:po_data, :graph))})
        data_gather_loop()
    end
  end

  @doc """
  Query the pulse oximeter data store in order to get statistics about blood
  oxygen levels including the durration of the data and the cutoff values for
  the minimum datetime and perfusion index ranges as well as maximum spo2
  range.

  The cutoff on the perfusion index is there to prevent bad readings from
  entering the average.  Unfortunately, the `Signal Quality` or `SIQ` numbers
  from the RAD8 and other pulse oximeters is not readable through the standard
  serial output. One day, perhaps the Philips IntelliVue output will be
  entirely decoded and open so that we can have nicer graphs and charts.

  Note: Each database entry is calculated as lasting one second, a better
  heuristic should be used in order to calculate time or at the very least,
  calculate percentages from samples and state the sample size instead. This
  would make the calculation device agnostic. The documentation in the manual
  for the RAD8 states 0.5 second sample rates but that's a lie, as all the
  timestamps from the device itself are approximately 1 second apart.
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

  @doc """
  Grabs data and creates a plot graph with multiple `y` datasets and only
  datetimes as the `x` dataset.
  """
  @spec graph_data(pos_integer, String.t()) :: svg :: binary()
  def graph_data(sample_size \\ 3600, graph_type \\ "line") do
    dataset = build_dataset(sample_size)

    module =
      case graph_type do
        "scatter" -> PointPlot
        _ -> LinePlot
      end

    options = [
      mapping: %{x_col: "Inserted At", y_cols: @y_cols},
      smoothed: true
    ]

    Plot.new(dataset, module, 600, 400, options)
    |> Plot.titles("Recent Data", "Approximately 1 Hour")
    |> Plot.plot_options(%{legend_setting: :legend_right})
    |> Plot.to_svg()
  end

  @doc """
  Graphs given BPM or SPO2 datapoints against time as a single line graph.
  """
  @spec graph_individual(
          times :: [DateTime.t()],
          samples :: [non_neg_integer()],
          title :: String.t()
        ) :: svg :: binary()
  def graph_individual(times, samples, title) do
    options = [
      mapping: %{x_col: :time, y_cols: [:sample]},
      smoothed: true
    ]

    Enum.zip(times, samples)
    |> Enum.map(fn {t, s} -> %{time: t, sample: s} end)
    |> Contex.Dataset.new()
    |> Plot.new(LinePlot, 400, 300, options)
    |> Plot.titles(title, "Live Feed")
    |> Plot.to_svg()
  end

  defp build_dataset(sample_size) do
    dt_cutoff = Timex.shift(DateTime.utc_now(), hours: -1)

    from(
      e in PulseOx.Schema.Event,
      select: %{
        "Inserted At" => e.inserted_at,
        "SPO2" => e.spo2,
        "BPM" => e.bpm,
        "Perf. Index" => e.perfusion_index
      },
      order_by: [desc: :inserted_at],
      where: e.inserted_at > ^dt_cutoff,
      limit: ^sample_size
    )
    |> Repo.all()
    |> Contex.Dataset.new()
  end

  defp calculate_time(count) do
    seconds = Enum.reduce(1..count, 0, fn _, acc -> 1.0 + acc end)
    minutes = seconds / 60.0

    if minutes > 60.0 do
      {:hrs, minutes / 60.0}
    else
      {:mins, minutes}
    end
  end

  defp add_data(por, [{:graph, data}]) do
    [por | data]
    |> Enum.take(@live_samples)
  end
end
