defmodule MySensors.Repo.Migrator do
  @moduledoc false
  @otp_app Mix.Project.config[:app]

  @doc false
  def run do
    [repo] = Application.get_env(@otp_app, :ecto_repos)
    setup(repo)
    migrate(repo)
  end

  def setup(repo) do
    db_file = Application.get_env(@otp_app, repo)[:database]

    unless File.exists?(db_file) do
      :ok = repo.__adapter__.storage_up(repo.config)
    end
  end

  @dialyzer :no_match
  def migrate(repo) do
    opts = [all: true]
    {:ok, pid, apps} = Mix.Ecto.ensure_started(repo, opts)

    migrator = &Ecto.Migrator.run/4

    migrations_path =
      Application.get_env(@otp_app, repo)[:priv]
      |> Kernel.<>("/migrations")

    pool = repo.config[:pool]

    migrated =
      if function_exported?(pool, :unboxed_run, 2) do
        pool.unboxed_run(repo, fn -> migrator.(repo, migrations_path, :up, opts) end)
      else
        migrator.(repo, migrations_path, :up, opts)
      end

    # Dialyzer doesn't like this for some reason.
    if is_pid(pid), do: repo.stop(pid)

    Mix.Ecto.restart_apps_if_migrated(apps, migrated)
    Process.sleep(500)
  end
end
