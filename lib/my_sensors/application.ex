defmodule MySensors.Application do
  @moduledoc false
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(MySensors.Repo, []),
      worker(MySensors.Broadcast, []),
      worker(MySensors.Gateway, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
