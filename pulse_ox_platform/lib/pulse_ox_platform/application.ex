defmodule PulseOxPlatform.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      PulseOxPlatform.Repo,
      # Start the Telemetry supervisor
      PulseOxPlatformWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PulseOxPlatform.PubSub},
      # Start the Endpoint (http/https)
      PulseOxPlatformWeb.Endpoint,
      {Nerves.UART, name: :reader},
      {Task, fn -> PulseOxPlatform.Data.data_gather_loop() end}
    ]

    opts = [strategy: :one_for_one, name: PulseOxPlatform.Supervisor]
    res = Supervisor.start_link(children, opts)

    PulseOxReader.init()
    PulseOxPlatform.Data.setup_ets()

    :timer.sleep(200)

    res
  end
end
