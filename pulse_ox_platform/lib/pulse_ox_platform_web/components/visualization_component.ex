defmodule PulseOxPlatformWeb.VisualizationComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div id="visualization" phx-update="replace">
        <%= @graph_style %>
      </div>
    """
  end
end
