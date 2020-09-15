defmodule PulseOxPlatform.Repo do
  use Ecto.Repo,
    otp_app: :pulse_ox_platform,
    adapter: Ecto.Adapters.Postgres
end
