defmodule MySensors.Broadcast do
  @moduledoc "Stage to Broadcast Repo Data."

  use GenServer

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc "Subscribe to events about MySensors Data."
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end

  # This gets called from the Context module.
  @doc false
  def notify(%{insert_or_update: resource}) do
    GenServer.cast(__MODULE__, {:insert_or_update, resource})
    {:ok, resource}
  end

  def notify(%{delete: resource}) do
    GenServer.cast(__MODULE__, {:delete, resource})
    {:ok, resource}
  end

  def notify(unknown) do
    {:error, {:unknown_arg, unknown}}
  end

  defmodule State do
    @moduledoc false
    defstruct [subscribers: []]
    @typedoc false
    @type t :: %__MODULE__{subscribers: [pid]}
  end

  def init([]) do
    state = struct(State)
    {:ok, state}
  end

  def handle_cast({action, resource}, state) do
    for pid <- state.subscribers do
      send pid, {:my_sensors, {action, resource}}
    end

    {:noreply, state}
  end

  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info({:DOWN, _, :process, pid, _reason}, state) do
    new_subscribers = List.delete(state.subscribers, pid)
    {:noreply, %{state | subscribers: new_subscribers}}
  end
end
