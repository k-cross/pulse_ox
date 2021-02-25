defmodule PulseOxPlatformWeb.VisualizationComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~L"""
      <div phx-update="replace">
        <%= @graph_style %>
      </div>
    """
  end
end
