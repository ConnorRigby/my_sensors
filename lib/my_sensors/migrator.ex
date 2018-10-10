defmodule MySensors.Migrator do
  @moduledoc false

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :migrate, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def migrate do
    repo = MySensors.Repo
    repo_ = Module.split(repo) |> List.last() |> Macro.underscore() |> to_string()
    otp_app = :code.priv_dir(:my_sensors)
    migrations_path = Path.join([to_string(otp_app), repo_, "migrations"])
    opts = [all: true, log: :debug]
    migrator = &Ecto.Migrator.run/4
    migrator.(repo, migrations_path, :up, opts)
    :ignore
  end
end
