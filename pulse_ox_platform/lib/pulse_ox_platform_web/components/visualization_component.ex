defmodule PulseOxPlatformWeb.VisualizationComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~L"""
      <div phx-update="replace">
        <%= @graph_style %>
      </div>
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
    """
  end
end
