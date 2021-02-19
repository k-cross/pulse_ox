defmodule PulseOxPlatformWeb.QueryComponent do
  use Phoenix.LiveComponent

  alias PulseOxPlatform.Data

  @impl true
  @doc """
  Tied to button that submits the parameters to perform analysis of SPO2 levels
  over a given durration of time and setting an upper limit, excluding all data
  points above the given value.
  """
  def render(assigns) do
    ~L"""
      <div phx-update="replace">
        <div><b>Average SPO2:</b> <%= @avg_spo2 %></div>
        <div><b>Durration:</b> <%= @durration %></div>
      </div>
      <div>
        <form phx-submit="analyze">
          <div>
            <label for="spo2_level">SPO2 Cutoff:</label>
            <input type="number" id="spo2_level" name="spo2_cutoff">
          </div>
          <div>
            <label for="time_cutoff">Lower Limit Date:</label>
            <input type="date" id="time_cutoff" name="time_barrier">
          </div>
          <div>
            <input type="submit">
          </div>
        </form>
      </div>
    """
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
    {:noreply, assign(socket, avg_spo2: to_string(Decimal.round(avg, 3)), durration: durration)}
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
