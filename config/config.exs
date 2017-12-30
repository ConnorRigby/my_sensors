# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :my_sensors, json_handler: Jason

import_config "#{Mix.env()}.exs"
