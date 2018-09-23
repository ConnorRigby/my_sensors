# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :my_sensors, ecto_repos: [MySensors.Repo]
import_config "#{Mix.env()}.exs"
