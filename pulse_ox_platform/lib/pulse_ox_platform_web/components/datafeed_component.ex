defmodule PulseOxPlatformWeb.DatafeedComponent do
  use Phoenix.LiveComponent

  @impl true
  @doc "The HTML that's updated and rendered for the numerical readings."
  def render(assigns) do
    ~L"""
      <section class="container" phx-update="replace">
          <div>
            <b>BPM:</b> <%= @bpm %>
          </div>
          <div>
            <b>SPO2:</b> <%= @spo2 %>
          </div>
          <div>
            <b>Perfusion Index:</b> <%= @pi %>
          </div>
          <div>
            <div><b>Timestamp:</b> <%= @datetime %> </div>
            <div><b>Alert:</b> <%= @alert %> </div>
            <div><b>Information:</b> <%= @info %> </div>
          </div>
      </section>
    """
  end

  @impl true
  @doc "Update the live numerical data on screen."
  def update([{:event, %PulseOxReader{} = por}], socket) do
    {:ok,
     assign(socket,
       bpm: por.bpm,
       spo2: por.spo2,
       pi: por.perfusion_index,
       alert: por.alert,
       info: por.info,
       datetime: por.datetime
     )}
  end

  def update(_, socket) do
    PulseOxReader.reconnect(:reader)

    {:ok,
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
