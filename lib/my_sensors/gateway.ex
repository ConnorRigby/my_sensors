defmodule MySensors.Gateway do
  @moduledoc "Handles parsed MySensors packets."
  use GenServer
  require Logger
  alias MySensors.{Packet, Node, Sensor, SensorValue, Context}

  use Packet.Constants

  @doc """
  Start a Gateway.
  * Transport - the mechanism in which [MySensors.Packet](MySensors.Packet.html)
    are exchanged.
  * Opts - opts passed to the transport.
  """
  def add_transport(transport, opts) do
    GenServer.call(__MODULE__, {:add_transport, transport, opts})
  end

  @doc "Send a packet."
  def write_packet(%Packet{} = packet) do
    GenServer.cast(__MODULE__, {:write_packet, packet})
  end

  @doc false
  def handle_packet(%Packet{} = packet) do
    GenServer.cast(__MODULE__, {:handle_packet, packet})
  end

  defmodule Transport do
    @moduledoc false
    defstruct [:module, :opts, :pid, :ref]
  end

  defmodule State do
    @moduledoc false
    defstruct [:transports]
  end

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc false
  def init([]) do
    {:ok, struct(State, transports: [])}
  end

  def terminate(reason, _state) do
    Logger.info "Gateway stopping: #{inspect reason}"
  end

  def handle_call({:add_transport, transport, opts}, _from, state) do
    case start_transport(transport, opts) do
      {:ok, pid} ->
        ref = Process.monitor(pid)
        tp_opts = [
          module: transport,
          opts: opts,
          pid: pid,
          ref: ref
        ]
        transport = struct(Transport, tp_opts)
        {:reply, :ok, %{state | transports: [transport | state.transports]}}
      {:error, reason} ->
        Logger.error "Failed to start transport: #{transport} - #{inspect reason}"
        {:reply, :error, state}
    end
  end

  def handle_cast({:handle_packet, packet}, state) do
    Logger.info "packet in: #{inspect packet}"
    case do_handle_packet(packet, state) do
      %State{} = state ->
        {:noreply, state}
      {:error, reason} ->
        Logger.error "Failed to handle packet: #{inspect packet}: #{inspect reason}"
        {:noreply, state}
    end
  end

  def handle_cast({:write_packet, packet}, state) do
    Logger.info "packet out: #{inspect packet}"

    for %{module: tp, pid: pid} <- state.transports do
      tp.write_packet(pid, packet)
    end
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state)
  when reason in [:normal, :shutdown] do
    item = find_transport(pid, ref, state)
    {:noreply, %{state | transports: List.delete(state.transports, item)}}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    case find_transport(pid, ref, state) do
      %Transport{} = tp ->
        Logger.error "Transport #{tp.module} died: #{inspect reason}"
        case start_transport(tp.module, tp.opts) do
          {:ok, pid} ->
            ref = Process.monitor(pid)
            tp_opts = [
              module: tp.module,
              opts: tp.opts,
              pid: pid,
              ref: ref
            ]
            transport = struct(Transport, tp_opts)
            {:noreply, %{state | transports: [transport | state.transports]}}
          {:error, reason} ->
            Logger.error "Failed to start transport: #{tp.monitor} - #{inspect reason}"
            {:noreply, state}
        end
      _ -> {:noreply, state}
    end
  end

  defp find_transport(pid, ref, state) do
    Enum.find(state.transports, fn(%{pid: s_pid, ref: s_ref}) ->
      (ref == s_ref) or (pid == s_pid)
    end)
  end

  defp start_transport(transport, opts) do
    with :ok <- validate_transport_module(transport),
      {:ok, opts} <- transport.opts(opts),
      {:ok, pid} <- GenServer.start(transport, opts) do
        {:ok, pid}
      else
        {:error, reason} -> {:error, reason}
        :ignore -> {:error, :ignore}
      end
  end

  defp validate_transport_module(module) when is_atom(module) do
    with true <- Code.ensure_loaded?(module),
      true <- function_exported?(module, :opts, 1)
    do
      :ok
    else
      _ -> {:error, :bad_behaviour}
    end
  end

  defp validate_transport_module(_), do: {:error, :bad_transport}

  # Handles packet by command.
  defp do_handle_packet(%Packet{command: @command_PRESENTATION, node_id: 0}, state) do
    state
  end

  defp do_handle_packet(%Packet{command: @command_PRESENTATION, child_sensor_id: @internal_NODE_SENSOR_ID} = packet, state) do
    with {:ok, %Node{}} <- Context.save_protocol(packet),
    {:ok, %Sensor{}} <- Context.save_sensor(packet) do
      state
    else
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_PRESENTATION} = packet, state) do
    case Context.save_sensor(packet) do
      {:ok, %Sensor{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_SET} = packet, state) do
    case Context.save_sensor_value(packet) do
      {:ok, %SensorValue{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_REQ}, state), do: state

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_BATTERY_LEVEL} = packet, state) do
    case Context.save_battery_level(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_TIME} = packet, state) do
    send_time(packet, state)
    state
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_ID_REQUEST} = packet, state) do
    case send_next_available_id(packet, state) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_CONFIG} = packet, state) do
    case send_config(packet, state) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_SKETCH_NAME} = packet, state) do
    case Context.save_sketch_name(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_SKETCH_VERSION} = packet, state) do
    case Context.save_sketch_version(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end


  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_LOG_MESSAGE} = packet, state) do
    Logger.info "Node #{packet.node_id} => #{packet.payload}"
    state
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_GATEWAY_READY}, state) do
    %{state | status: Map.put(state.status, :ready, true)}
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL} = packet, state) do
    Logger.debug "Unhandled internal message: #{inspect packet}"
    state
  end

  defp do_handle_packet(%Packet{command: @command_STREAM}, state),
    do: state

  @spec send_time(Packet.t, State.t) :: :ok | {:error, term}
  defp send_time(%Packet{} = packet, state) do
    time = :os.system_time(:seconds)
    opts = [command: @command_INTERNAL,
            ack: @ack_FALSE,
            node_id: packet.node_id,
            child_sensor_id: packet.child_sensor_id,
            type: @internal_TIME,
            payload: to_string(time)
          ]
    send_packet = struct(Packet, opts)
    state.transport.write(send_packet)
  end

  @spec send_config(Packet.t, State.t) :: {:ok, Node.t} | {:error, term}
  defp send_config(%Packet{} = packet, state) do
    opts = [
      payload: "I",
      child_sensor_id: @internal_NODE_SENSOR_ID,
      node_id: packet.node_id,
      command: @command_INTERNAL,
      type: @internal_CONFIG,
      ack: @ack_FALSE
    ]
    send_packet = struct(Packet, opts)
    for %{moduld: tp, pid: pid} <- state.transports do
      tp.write(pid,  send_packet)
      Context.save_config(send_packet)
    end
    state
  end

  @spec send_next_available_id(Packet.t, State.t) :: {:ok, Node.t} | {:error, term}
  defp send_next_available_id(%Packet{}, state) do

    node = Context.new_node()

    packet_opts = [
      node_id: @internal_BROADCAST_ADDRESS,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      command: @command_INTERNAL,
      type: @internal_ID_RESPONSE,
      ack: @ack_FALSE,
      payload: node.id
    ]
    send_packet = struct(Packet, packet_opts)
    for %{module: tp, pid: pid} <- state.transports do
      IO.puts "hello??: #{inspect state}"
      tp.write(pid,  send_packet)
    end
    state
  end
end
