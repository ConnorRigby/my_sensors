defmodule MySensors.Repo do
  @moduledoc "Repo for MySensors data."
  use Ecto.Repo,
    otp_app: :my_sensors,
    adapter: Sqlite.Ecto2
end
