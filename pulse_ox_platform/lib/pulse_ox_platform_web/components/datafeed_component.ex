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

  def update([{:event, %PulseOxReader{} = por}], socket) do
    %{
      bpm: por.bpm,
      spo2: por.spo2,
      pi: por.perfusion_index,
      alert: por.alert,
      info: por.info,
      datetime: por.datetime
    }
    |> update(socket)
  end

  def update(_, socket) do
    PulseOxReader.reconnect(:reader)

    %{
      bpm: "disconnected",
      spo2: "disconnected",
      pi: "disconnected",
      alert: "disconnected",
      info: "disconnected",
      datetime: "disconnected"
    }
    |> update(socket)
  end
end
