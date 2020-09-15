# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pulse_ox_platform, ecto_repos: [PulseOxPlatform.Repo]

config :pulse_ox_platform, PulseOxPlatform.Repo,
  database: "pulse_ox_dev",
  username: "pulseox",
  password: "pulseoximeter",
  hostname: "localhost"

# Configures the endpoint
config :pulse_ox_platform, PulseOxPlatformWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8e2EKsnoH5bLI1rWvv+oy0y2WLVs9E1bomV0wcZTA9y7CeWm+9eGrGpUJJyDFPS/",
  render_errors: [view: PulseOxPlatformWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PulseOxPlatform.PubSub,
  live_view: [signing_salt: "WzIriLnq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
