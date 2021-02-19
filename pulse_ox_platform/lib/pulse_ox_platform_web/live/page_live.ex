defmodule PulseOxPlatformWeb.PageLive do
  use PulseOxPlatformWeb, :live_view

  alias PulseOxPlatformWeb.{
    DatafeedComponent,
    QueryComponent,
    VisualizationComponent
  }

  @impl true
  def render(assigns) do
    ~L"""
      <section class="phx-hero">
        <h1>Pulse Oximeter Readings</h1>
      </section>
      <%=
        live_component @socket,
        DatafeedComponent,
        id: :datafeed,
        bpm: @bpm,
        spo2: @spo2,
        pi: @pi,
        datetime: @datetime,
        alert: @alert,
        info: @info
      %>
      <section class="container">
        <div>
          <%=
            live_component @socket,
            QueryComponent,
            id: :analyze,
            avg_spo2: @avg_spo2,
            durration: @durration
          %>
          <%= 
            live_component @socket,
            VisualizationComponent,
            id: :visualize 
          %>
        </div>
      </section>
    """
  end

  @impl true
  @doc "Initialization of the socket connection, bootstraping the read loop."
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 250)

    {:ok,
     assign(socket,
       bpm: "initializing",
       spo2: "initializing",
       pi: "initializing",
       alert: "initializing",
       info: "initializing",
       datetime: "initializing",
       avg_spo2: "",
       durration: ""
     )}
  end

  @doc "Update the live numerical data on screen."
  def update(socket) do
    {:ok, s} = DatafeedComponent.update(:ets.lookup(:po_data, :event), socket)
    {:noreply, s}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 500)
    update(socket)
  end
end
