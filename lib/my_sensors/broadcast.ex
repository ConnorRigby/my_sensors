defmodule MySensors.Broadcast do
  @moduledoc """
  Elixir Broadcast mechanism for MySensors data.
  Will receive messages in the shape of:
  `{:my_sensors, {type, data}}`
  where `type` will be:
    * `insert_or_update`
    * `delete`
  and `data` will be a `Node` struct.
  """

  alias MySensors.Node
  require Logger
  @name MySensorsRegistry

  @doc false
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc false
  def start_link(_args) do
    Registry.start_link(keys: :duplicate, name: @name)
  end

  @doc """
  Subscribe to events about MySensors Data.
  """
  def subscribe() do
    {:ok, _} = Registry.register(@name, __MODULE__, [])
    :ok
  end

  def dispatch(msg) do
    Registry.dispatch(@name, __MODULE__, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:my_sensors, msg})
    end)
  end
end
