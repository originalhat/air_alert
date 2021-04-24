# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :air_alert,
  ecto_repos: [AirAlert.Repo]

# Configures the endpoint
config :air_alert, AirAlertWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pRaSccnhAQF4chRTb7GOUmqlTjVDcXoCTCK7/PFCU1VSLAKtohapfp/+8twEd3mz",
  render_errors: [view: AirAlertWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AirAlert.PubSub,
  live_view: [signing_salt: "hp0weToS"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
