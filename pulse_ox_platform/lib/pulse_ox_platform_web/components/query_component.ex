defmodule PulseOxPlatformWeb.QueryComponent do
  use Phoenix.LiveComponent

  @impl true
  @doc """
  Tied to button that submits the parameters to perform analysis of SPO2 levels
  over a given durration of time and setting an upper limit, excluding all data
  points above the given value.
  """
  def render(assigns) do
    ~H"""
    <div id="analyze">
      <div id="analysis-query" phx-update="replace">
        <table>
          <tr><td><b>Average SPO2</b></td><td><%= @avg_spo2 %></td></tr>
          <tr><td><b>Durration</b></td><td><%= @durration %></td></tr>
        </table>
      </div>
      <div>
        <form phx-submit="analyze">
          <table>
            <tr>
              <th><label for="spo2_level">SPO2 Cutoff</label></th>
              <th><label for="time_cutoff">Lower Limit Date</label></th>
            </tr>
            <tr>
              <td><input type="number" id="spo2_level" name="spo2_cutoff"></td>
              <td><input type="date" id="time_cutoff" name="time_barrier"></td>
              <td><input type="submit"></td>
            </tr>
          </table>
        </form>
      </div>
    </div>
    """
  end
end
