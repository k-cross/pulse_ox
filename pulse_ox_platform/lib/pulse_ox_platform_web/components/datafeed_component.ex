defmodule PulseOxPlatformWeb.DatafeedComponent do
  use Phoenix.LiveComponent

  @impl true
  @doc "The HTML that's updated and rendered for the numerical readings."
  def render(assigns) do
    ~L"""
      <section class="container" phx-update="replace">
          <table>
            <tr><td><b>BPM</b></td><td><%= @bpm %></td></tr>
            <tr><td><b>SPO2</b></td><td><%= @spo2 %></td></tr>
            <tr><td><b>Perfusion Index</b></td><td><%= @pi %></td></tr>
            <tr><td><b>Timestamp</b></td><td><%= @datetime %></td></tr>
            <tr><td><b>Alert</b></td><td><%= @alert %></td></tr>
            <tr><td><b>Information</b></td><td><%= @info %></td></tr>
          </table>
      </section>
    """
  end

  @impl true
  @doc "Update the live numerical data on screen."
  def update(%{} = assigns, socket), do: {:ok, assign(socket, assigns)}
end
