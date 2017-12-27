[![CircleCI](https://circleci.com/gh/ConnorRigby/my_sensors.svg?style=svg)](https://circleci.com/gh/ConnorRigby/my_sensors)
# MySensors

## Usage

The package can be installed
by adding `my_sensors` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:my_sensors, "~> 0.1.0"}
  ]
end
```

then in `config.exs`:
```elixir
config :my_sensors, MySensors.Repo,
  adapter: Sqlite.Ecto2, # or postgres if you want.
  database: "/path/to/my_sensors_db.sqlite3",
  # Don't change this one.
  priv: "priv/repo"

config :my_sensors, ecto_repos: [MySensors.Repo]

config :my_sensors, json_handler: Jason # Or Poison if you want.
```

Before starting the app you will need to do:

```bash
mix ecto.migrate -r MySensors.Repo
```

or

```elixir
Mix.Tasks.Ecto.Migrate.run ["-r", "MySensors.Repo"]
```

or add
```elixir
worker(Task, [MySensors.Repo.Migrator, :run, []], [restart: :transient]),
```

to your Application startup.
