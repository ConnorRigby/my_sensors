# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :my_sensors, [
  lan_app: [ port: 4001 ]
]

config :my_sensors, MySensors.Repo,
  adapter: Sqlite.Ecto2,
  database: "my_sensors.sqlite3",
  priv: "priv/repo"

config :my_sensors, ecto_repos: [MySensors.Repo]

import_config "#{Mix.env()}.exs"
