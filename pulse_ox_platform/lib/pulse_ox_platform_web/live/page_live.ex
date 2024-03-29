defmodule PulseOxPlatformWeb.PageLive do
  use PulseOxPlatformWeb, :live_view

  alias PulseOxPlatform.Data

  alias PulseOxPlatformWeb.{
    DatafeedComponent,
    QueryComponent,
    VisualizationComponent
  }

  @impl true
  def render(assigns) do
    ~L"""
      <section class="phx-hero">
        <h1>Pulse Oximeter Readings</h1>
      </section>
      <%=
        live_component @socket,
        DatafeedComponent,
        id: :datafeed,
        bpm: @bpm,
        spo2: @spo2,
        pi: @pi,
        datetime: @datetime,
        alert: @alert,
        info: @info
      %>
      <%= 
        live_component @socket,
        VisualizationComponent,
        id: :live_spo2,
        graph_style: @spo2_graph
      %>
      <%= 
        live_component @socket,
        VisualizationComponent,
        id: :live_bpm,
        graph_style: @bpm_graph
      %>
      <section class="container">
        <div>
          <%=
            live_component @socket,
            QueryComponent,
            id: :analyze,
            avg_spo2: @avg_spo2,
            durration: @durration
          %>
          <%= 
            live_component @socket,
            VisualizationComponent,
            id: :combined_charts,
            graph_style: @graph_style
          %>
          <div>
            <table>
              <tr>
                <th><b>Graph Type</b></th>
              </tr>
              <tr>
                <td>
                  <input type="radio" id="line_plot" name="graph_type" value="line" phx-click="graph_type">
                  <label for="line_plot">Line</label>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="radio" id="scatter_plot" name="graph_type" value="scatter" phx-click="graph_type">
                  <label for="scatter_plot">Scatter</label>
                </td>
              </tr>
            </table>
          </div>
        </div>
      </section>
    """
  end

  @impl true
  @doc "Initialization of the socket connection, bootstraping the read loop."
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 250)

    {:ok,
     assign(socket,
       bpm: "initializing",
       spo2: "initializing",
       pi: "initializing",
       alert: "initializing",
       info: "initializing",
       datetime: "initializing",
       avg_spo2: "",
       durration: "",
       spo2_graph: Data.graph_individual([DateTime.utc_now()], [0], "Initializing"),
       bpm_graph: Data.graph_individual([DateTime.utc_now()], [0], "Initializing"),
       graph_style: Data.graph_data(3600, "line")
     )}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 500)

    assigns = read(:ets.lookup(:po_data, :event))
    send_update(self(), DatafeedComponent, Map.put(assigns, :id, :datafeed))

    {l_bpm, l_spo2, _l_pi, l_dt} = format_data()

    send_update(
      self(),
      VisualizationComponent,
      %{id: :live_bpm, graph_style: Data.graph_individual(l_dt, l_bpm, "Heart BPM")}
    )

    send_update(
      self(),
      VisualizationComponent,
      %{id: :live_spo2, graph_style: Data.graph_individual(l_dt, l_spo2, "SPO2")}
    )

    {:noreply, socket}
  end

  @impl true
  @doc """
  Tracks the user interactions of clickable events and delegates the
  responsibility to the appropriate modules to handle the rendering updates and
  data changes.
  """
  def handle_event("analyze", args, socket) do
    {spo2_level, lower_limit_date} = parse_args(args)
    {avg, {time_unit, amnt}} = Data.analyze_spo2(lower_limit_date, spo2_level)
    durration = to_string(Float.round(amnt, 3)) <> " " <> to_string(time_unit)

    send_update(
      self(),
      QueryComponent,
      %{avg_spo2: to_string(Decimal.round(avg, 3)), durration: durration, id: :analyze}
    )

    {:noreply, socket}
  end

  def handle_event("graph_type", args, socket) do
    send_update(
      self(),
      VisualizationComponent,
      %{id: :combined_charts, graph_style: Data.graph_data(3600, args["value"])}
    )

    {:noreply, socket}
  end

  defp parse_args(%{"spo2_cutoff" => spo2_cutoff, "time_barrier" => date}),
    do: {spo2_cutoff, date} |> normalize_args()

  defp parse_args(%{"spo2_cutoff" => spo2_cutoff}), do: {spo2_cutoff, nil} |> normalize_args()
  defp parse_args(%{"time_barrier" => date}), do: {nil, date} |> normalize_args()
  defp parse_args(_), do: {nil, nil} |> normalize_args()

  defp normalize_args({nil, a2}), do: normalize_args({100, a2})
  defp normalize_args({"", a2}), do: normalize_args({100, a2})

  defp normalize_args({a1, nil}),
    do: normalize_args({a1, DateTime.utc_now() |> Timex.shift(days: -1)})

  defp normalize_args({a1, ""}),
    do: normalize_args({a1, DateTime.utc_now() |> Timex.shift(days: -1)})

  defp normalize_args({a1, a2}) when is_binary(a1),
    do: normalize_args({Integer.parse(a1) |> elem(0), a2})

  defp normalize_args({a1, a2}) when is_binary(a2),
    do: {a1, Timex.parse(a2, "{YYYY}-{0M}-{D}") |> elem(1)}

  defp normalize_args(args), do: args

  defp read([{:event, %PulseOxReader{} = por}]) do
    %{
      bpm: por.bpm,
      spo2: por.spo2,
      pi: por.perfusion_index,
      alert: por.alert,
      info: por.info,
      datetime: por.datetime
    }
  end

  defp read([{:event, _}]) do
    PulseOxReader.reconnect(:reader)

    %{
      bpm: "disconnected",
      spo2: "disconnected",
      pi: "disconnected",
      alert: "disconnected",
      info: "disconnected",
      datetime: "disconnected"
    }
  end

  defp read([{:graph, data}]), do: data

  defp format_data do
    :ets.lookup(:po_data, :graph)
    |> read()
    |> Enum.reduce({[], [], [], []}, fn
      :disconnected, {l_bpm, l_spo2, l_pi, l_dt} ->
        {
          [0 | l_bpm],
          [0 | l_spo2],
          [0 | l_pi],
          [DateTime.utc_now() | l_dt]
        }

      %PulseOxReader{bpm: bpm, perfusion_index: pi, spo2: spo2, datetime: dt},
      {l_bpm, l_spo2, l_pi, l_dt} ->
        {
          [bpm | l_bpm],
          [spo2 | l_spo2],
          [pi | l_pi],
          [dt | l_dt]
        }
    end)
  end
end
