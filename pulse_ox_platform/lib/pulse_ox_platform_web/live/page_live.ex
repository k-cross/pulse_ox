defmodule PulseOxPlatformWeb.PageLive do
  use PulseOxPlatformWeb, :live_view

  alias PulseOxPlatform.Data

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
       min_spo2: "",
       max_spo2: ""
     )}
  end

  @impl true
  @doc """
  Tied to button that submits the parameters to perform analysis of SPO2 levels
  over a given durration of time and setting an upper limit, excluding all data
  points above the given value.
  """
  def handle_event("analyze", args, socket) do
    {spo2_level, lower_limit_date} = parse_args(args)
    {avg, {time_unit, amnt}} = Data.analyze_spo2(lower_limit_date, spo2_level)
    durration = to_string(Float.round(amnt, 3)) <> " " <> to_string(time_unit)
    {:noreply, assign(socket, avg_spo2: avg, durration: durration)}
  end

  @impl true
  @doc "The main updated read loop."
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 250)

    case :ets.lookup(:po_data, :event) do
      [{:event, %PulseOxReader{} = por}] ->
        {:noreply,
         assign(socket,
           bpm: por.bpm,
           spo2: por.spo2,
           pi: por.perfusion_index,
           alert: por.alert,
           info: por.info,
           datetime: por.datetime
         )}

      _ ->
        PulseOxReader.reconnect(:reader)

        {:noreply,
         assign(socket,
           bpm: "disconnected",
           spo2: "disconnected",
           pi: "disconnected",
           alert: "disconnected",
           info: "disconnected",
           datetime: "disconnected"
         )}
    end
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
end
