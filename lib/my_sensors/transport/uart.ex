defmodule MySensors.Transport.UART do
  @moduledoc "UART Tranport for MySensors."
  alias MySensors.{Gateway, Packet}
  @behaviour MySensors.Transport
  alias Nerves.UART
  use GenServer
  require Logger

  def write(pid, packet), do: GenServer.call(pid, {:write, packet})

  @doc """
  Callback for [MySensors.Transport](MySensors.Transport.html)
  * device - Required. Example: /dev/ttyUSB0
  * speed - default: 115200,
  * seperator - default: "\\n"
  """
  def opts(opts) do
    with {:ok, device} <- Keyword.fetch(opts, :device),
      speed <- Keyword.get(opts, :speed, 115200),
      seperator <- Keyword.get(opts, :seperator, "\n")
    do
      {:ok, [device: device, speed: speed, seperator: seperator]}
    else
      :error -> {:error, {:missing_opt, :device}}
    end
  end

  def init(opts) do
    {:ok, uart} = UART.start_link()
    case UART.open(uart, opts[:device], active: true, speed: opts[:speed]) do
      :ok ->
        :ok = UART.configure(uart, framing: {UART.Framing.Line, separator: opts[:seperator]})
        {:ok, %{uart: uart}}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_info({:nerves_uart, _, {:error, error}}, state) do
    {:stop, error, state}
  end

  def handle_info({:nerves_uart, _, {:partial, _}}, state) do
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _, command}, state) do
    with {:ok, decoded} <- Packet.decode(command) do
      Gateway.handle_packet(decoded)
      {:noreply, state}
    else
      {:error, reason} ->
        Logger.error "Error decoding packet: #{command} #{inspect reason}"
        {:noreply, state}
    end
  end

  def handle_call({:write, packet}, _from, state) do
    with {:ok, packet} <- Packet.encode(packet) do
      r = UART.write(state.uart, packet)
      {:reply, r, state}
    else
      {:error, reason} ->
        Logger.error "Failed to encode packet: #{inspect packet} #{inspect reason}"
        {:reply, {:error, reason}, state}
    end
  end
end
