# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tartupark,
  ecto_repos: [Tartupark.Repo],
  extensions: [{Geo.PostGIS.Extension, library: Geo}]

# Configures the endpoint
config :tartupark, Tartupark.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EpETStUwarxTanYsLPjBjuHErWoRmLAKYEwCeFpkhAAljk6terWMmCzbyM5DQ16x",
  render_errors: [view: Tartupark.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tartupark.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "Tartupark",
  ttl: {30, :days},
  allowed_drift: 2000,
  secret_key: "quiHI7/LPs8hKGYtoPJjpztLil67l3oPFlY9EVDkpFHq9hOQ8/9/zSlQY8wj+Jiy",
  serializer: Tartupark.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :tartupark, gmaps_api_key: "AIzaSyCDEm-ZYWAGGfLsX54mAjVV-GbyRI-_CDU"
