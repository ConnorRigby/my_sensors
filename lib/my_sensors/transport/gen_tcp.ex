defmodule MySensors.Transport.TCP do
  alias MySensors.{Gateway, Packet}
  @behaviour MySensors.Transport
  use GenServer
  require Logger

  def write(client, packet), do: GenServer.call(client, {:write, packet})

  def opts(opts) do
    host = Keyword.get(opts, :host, 'localhost')
    port = Keyword.get(opts, :port, 5003)
    {:ok, [host: host, port: port]}
  end

  def init(opts) do
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)
    socket_opts = [
      :binary,
      {:active, true},
      {:packet, :line}
    ]
    {:ok, socket} = :gen_tcp.connect(host, port, socket_opts)
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, _socket, info}, state) do
    case Packet.decode(info) do
      {:ok, %Packet{} = packet} ->
        Gateway.handle_packet(packet)
      {:error, reason} ->
        Logger.error "error decoding TCP packet: #{info} : #{inspect reason}"
    end
    {:noreply, state }
  end

  def handle_info(info, state) do
    IO.inspect info
    {:noreply, state}
  end

  def handle_call({:write, %Packet{} = packet}, _from, state) do
    case Packet.encode(packet) do
      {:ok, bin} ->
        :gen_tcp.send(state.socket, bin <> "\n")
        {:reply, :ok, state}
      {:error, reason} ->
        Logger.error "error encodeing packet: #{inspect packet}: #{inspect reason}"
        {:reply, {:error, reason}, state}
    end
  end

  def terminate(_, state) do
    if state.socket do
      :gen_tcp.shutdown(state.socket, :write)
      :gen_tcp.shutdown(state.socket, :read)
      :gen_tcp.close(state.socket)
    end
  end
end
