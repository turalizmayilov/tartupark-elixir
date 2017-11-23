use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tartupark, Tartupark.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tartupark, Tartupark.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tartupark_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# config :takso, decision_timeout: 3000   # 3 seconds
config :takso, :http_client, Takso.HTTPoisonMock