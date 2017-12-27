use Mix.Config
config :my_sensors, MySensors.Repo,
  adapter: Sqlite.Ecto2,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "my_sensors_test.sqlite3",
  loggers: [],
  priv: "priv/repo",
  ownership_timeout: :infinity
