defmodule MySensors.Transport.Local do
  @moduledoc "Elixir GenServer implementation of a MySensors.Transport."
  @behaviour MySensors.Transport
  alias MySensors.{Gateway, Packet}

  use GenServer
  require Logger

  @doc "Dispatch a packet to the Gateway. This is a test/debugging function."
  def dispatch(%Packet{} = packet) do
    GenServer.call(__MODULE__, {:dispatch, packet})
  end

  @doc "Register a process to receive callback packets."
  def register(pid) do
    GenServer.call(__MODULE__, {:register, pid})
  end

  @doc "Stop the transport."
  def stop(reason \\ :shutdown) do
    GenServer.stop(__MODULE__, reason)
  end

  @doc false
  def write(pid, %Packet{} = packet) do
    GenServer.call(pid, {:write, packet})
  end

  def opts(opts), do: {:ok, opts}

  @doc false
  def init(_) do
    Process.register(self(), __MODULE__)
    {:ok, %{registered: []}}
  end

  def terminate(reason, _) do
    Process.unregister(__MODULE__)
    Logger.warn "Local transport died: #{inspect reason}"
  end

  def handle_call({:register, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | registered: [pid | state.registered]}}
  end

  def handle_call({:dispatch, packet}, _, state) do
    Gateway.handle_packet(packet)
    {:reply, :ok, state}
  end

  def handle_call({:write, packet}, _, state) do
    for pid <- state.registered do
      send pid, packet
    end
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    {:noreply, %{state | registered: List.delete(state.registered, pid)}}
  end
end
