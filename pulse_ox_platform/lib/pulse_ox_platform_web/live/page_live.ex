defmodule PulseOxPlatformWeb.PageLive do
  use PulseOxPlatformWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :update, 250)

    case :ets.lookup(:po_data, :event) do
      [{:event, %PulseOxReader{} = por}] ->
        {:ok,
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

  @impl true
  def render(assigns) do
    ~L"""
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
      <span><b>Timestamp:</b> <%= @datetime %> </span>
      <span><b>Alert:</b> <%= @alert %> </span>
      <span><b>Information:</b> <%= @info %> </span>
    </div>
    """
  end

  @impl true
  def handle_info(:update, socket) do
    {:no_reply, socket}
  end
end
