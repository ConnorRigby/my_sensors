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

  use GenServer
  alias MySensors.Node
  require Logger

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Subscribe to events about MySensors Data.
  """
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end

  defmodule State do
    @moduledoc false
    defstruct subscribers: []
    @typedoc false
    @type t :: %__MODULE__{subscribers: [GenServer.server()]}
  end

  def init([]) do
    {:ok, _} = :mnesia.subscribe({:table, Node, :detailed})
    state = struct(State)
    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.error("Broadcast module terminated: #{inspect(reason)}")
    :mnesia.unsubscribe({:table, Node, :detailed})
  end

  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info({:mnesia_table_event, {:write, Node, record, _, _}}, state) do
    do_dispatch_events(:insert_or_update, [record], state)
    {:noreply, state}
  end

  def handle_info({:mnesia_table_event, {:delete, Node, {Node, _id}, records, _}}, state) do
    do_dispatch_events(:delete, records, state)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, pid, _reason}, state) do
    new_subscribers = List.delete(state.subscribers, pid)
    {:noreply, %{state | subscribers: new_subscribers}}
  end

  def do_dispatch_events(action, events, state) do
    for record <- events do
      for pid <- state.subscribers do
        send(pid, {:my_sensors, {action, Node.to_struct(record)}})
      end
    end
  end
end
