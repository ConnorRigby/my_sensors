use Mix.Config

config :my_sensors, MySensors.Repo,
  adapter: Sqlite.Ecto2,
  pool_size: 1,
  database: "my_sensors_dev.sqlite"
