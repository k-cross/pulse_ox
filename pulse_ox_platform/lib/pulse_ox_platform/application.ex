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
      # Start a worker by calling: PulseOxPlatform.Worker.start_link(arg)
      # {PulseOxPlatform.Worker, arg}
      {Task, fn -> PulseOxPlatform.Data.data_gather_loop() end}
    ]

    PulseOxReader.init()
    PulseOxPlatform.Data.setup_ets()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PulseOxPlatform.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PulseOxPlatformWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
