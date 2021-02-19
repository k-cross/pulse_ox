defmodule PulseOxPlatformWeb.VisualizationComponent do
  use Phoenix.LiveComponent

  alias PulseOxPlatform.Data

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-update="replace">
      <%= Data.graph_data() %>
    </div>
    """
  end
end
