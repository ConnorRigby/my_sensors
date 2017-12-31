defmodule MySensors.Broadcast do
  @moduledoc """
  Elixir Broadcast mechanism for MySensors data.
  Will receive messages in the shape of:
  `{:my_sensors, {type, data}}`
  where `type` will be:
    * `insert_or_update`
    * `delete`
  and `data` will be any `Node`, `Sensor`, or `SensorValue` struct.
  """

  use GenServer
  alias MySensors.Node

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc """
  Subscribe to events about MySensors Data.
  """
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end

  defmodule State do
    @moduledoc false
    defstruct [subscribers: []]
    @typedoc false
    @type t :: %__MODULE__{subscribers: [GenServer.server()]}
  end

  def init([]) do
    :mnesia.subscribe({:table, Node, :detailed})
    state = struct(State)
    {:ok, state}
  end

  def terminate(reason, _state) do
    :mnesia.unsubscribe({:table, Node, :detailed})
  end

  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info({:mnesia_table_event, {:write, Node, record, _, _}}, state) do
    for pid <- state.subscribers do
      send pid, {:my_sensors, {:insert_or_update, Node.to_struct(record)}}
    end
    {:noreply, state}
  end

  def handle_info({:mnesia_table_event, {:delete, Node, record, _, _}}, state) do
    for pid <- state.subscribers do
      send pid, {:my_sensors, {:delete, Node.to_struct(record)}}
    end
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, pid, _reason}, state) do
    new_subscribers = List.delete(state.subscribers, pid)
    {:noreply, %{state | subscribers: new_subscribers}}
  end
end
