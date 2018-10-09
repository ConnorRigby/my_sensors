defmodule MySensors.Gateway do
  @moduledoc "Handles parsed MySensors packets."
  use GenServer
  require Logger
  alias MySensors.{Packet, Node, Sensor, SensorValue, Context}

  use Packet.Constants

  # Each node has 10 seconds to respond
  # to heart messages.
  @heart_timeout_ms 10_000

  # Every 30 seconds start a timer for _every_ node.
  @heart_global_timeout_ms 30_000

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

  # Will be called by a transport.
  @doc false
  def handle_packet(%Packet{} = packet) do
    GenServer.cast(__MODULE__, {:handle_packet, packet})
  end

  defmodule Transport do
    @moduledoc false
    defstruct [:module, :opts, :pid, :ref]
    @typedoc false
    @type t :: %__MODULE__{
            module: module,
            opts: Keyword.t(),
            pid: GenServer.server(),
            ref: reference()
          }
  end

  defmodule State do
    @moduledoc false
    @typedoc false
    @type t :: %__MODULE__{
            transports: [Transport.t()],
            hearts: %{optional(integer) => reference}
          }
    defstruct [:transports, :hearts]
  end

  @doc false
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def init([]) do
    start_global_heart_timer()
    {:ok, struct(State, transports: [], hearts: %{})}
  end

  def terminate(_reason, _state) do
    Logger.info("Gateway stopping")
  end

  def handle_call({:add_transport, transport, opts}, _from, state) do
    pid = Process.whereis(transport)

    if is_pid(pid) and Process.alive?(pid) do
      {:reply, {:error, {:already_started, pid}}, state}
    else
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

          discovery_packet = %MySensors.Packet{
            ack: @ack_FALSE,
            child_sensor_id: @internal_NODE_SENSOR_ID,
            command: @command_INTERNAL,
            node_id: @internal_BROADCAST_ADDRESS,
            payload: "",
            type: @internal_DISCOVER_REQUEST
          }

          transport.module.write(pid, discovery_packet)
          {:reply, {:ok, pid}, %{state | transports: [transport | state.transports]}}

        {:error, reason} ->
          Logger.error("Failed to start transport: #{transport} - #{inspect(reason)}")
          {:reply, {:error, reason}, state}
      end
    end
  end

  def handle_cast({:handle_packet, packet}, state) do
    case do_handle_packet(packet, state) do
      %State{} = state ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Failed to handle packet: #{inspect(packet)}: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  def handle_cast({:write_packet, packet}, state) do
    do_write(state, packet)
    {:noreply, state}
  end

  def handle_info({@internal_HEARTBEAT_REQUEST, :global}, state) do
    state =
      Enum.reduce(Context.all_nodes(), state, fn %Node{id: id}, state ->
        maybe_start_heart_timer(state, id)
      end)

    start_global_heart_timer()
    {:noreply, state}
  end

  # This is the message that comes from maybe_start_heart(state, id)
  def handle_info({@internal_HEARTBEAT_REQUEST, id}, state) do
    case Context.get_id_status(id) do
      {:error, _} ->
        :ok

      "unknown" ->
        :ok

      _ ->
        Context.set_id_status(id, "unknown")
        Logger.warn("Node not responding!! #{id}")
    end

    {:noreply, %{state | hearts: Map.delete(state.hearts, id)}}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state)
      when reason in [:normal, :shutdown] do
    item = find_transport(pid, ref, state)
    {:noreply, %{state | transports: List.delete(state.transports, item)}}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    case find_transport(pid, ref, state) do
      %Transport{} = tp ->
        Logger.error("Transport #{tp.module} died: #{inspect(reason)}")

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
            Logger.error("Failed to start transport: #{tp.monitor} - #{inspect(reason)}")
            {:noreply, state}
        end

      _ ->
        {:noreply, state}
    end
  end

  defp find_transport(pid, ref, state) do
    Enum.find(state.transports, fn %{pid: s_pid, ref: s_ref} ->
      ref == s_ref or pid == s_pid
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
         true <- function_exported?(module, :opts, 1) do
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

  defp do_handle_packet(
         %Packet{command: @command_PRESENTATION, child_sensor_id: @internal_NODE_SENSOR_ID} =
           packet,
         state
       ) do
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

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_BATTERY_LEVEL} = packet,
         state
       ) do
    case Context.save_battery_level(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_TIME} = packet, state) do
    send_time(packet, state)
    state
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_ID_REQUEST} = packet,
         state
       ) do
    case send_next_available_id(packet, state) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_CONFIG} = packet,
         state
       ) do
    case send_config(packet, state) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_SKETCH_NAME} = packet,
         state
       ) do
    case Context.save_sketch_name(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_SKETCH_VERSION} = packet,
         state
       ) do
    case Context.save_sketch_version(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_LOG_MESSAGE} = packet,
         state
       ) do
    Logger.info("Node #{packet.node_id} => #{packet.payload}", node_id: packet.node_id)
    state
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL, type: @internal_GATEWAY_READY}, state) do
    state
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_DISCOVER_RESPONSE} = packet,
         state
       ) do
    case Context.save_node(packet) do
      {:ok, %Node{}} -> state
      err -> err
    end
  end

  defp do_handle_packet(
         %Packet{command: @command_INTERNAL, type: @internal_HEARTBEAT_RESPONSE} = packet,
         state
       ) do
    case Context.save_node(packet) do
      {:ok, %Node{id: id}} ->
        maybe_cancel_heart_timer(state, id)

      err ->
        err
    end
  end

  defp do_handle_packet(%Packet{command: @command_INTERNAL} = packet, state) do
    Logger.warn("Unhandled internal message: #{inspect(packet)}")
    state
  end

  defp do_handle_packet(%Packet{command: @command_STREAM}, state),
    do: state

  @spec send_time(Packet.t(), State.t()) :: :ok | {:error, term}
  defp send_time(%Packet{} = packet, state) do
    time = :os.system_time(:seconds)

    opts = [
      command: @command_INTERNAL,
      ack: @ack_FALSE,
      node_id: packet.node_id,
      child_sensor_id: packet.child_sensor_id,
      type: @internal_TIME,
      payload: to_string(time)
    ]

    send_packet = struct(Packet, opts)
    res = do_write(state, send_packet)

    if Enum.all?(res, &match?(:ok, &1)) do
      :ok
    else
      {:error, :failed_to_send}
    end
  end

  @spec send_config(Packet.t(), State.t()) :: {:ok, Node.t()} | {:error, term}
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
    res = do_write(state, send_packet)

    if Enum.all?(res, &match?(:ok, &1)) do
      Context.save_config(send_packet)
    else
      {:error, :failed_to_send}
    end
  end

  @spec send_next_available_id(Packet.t(), State.t()) :: {:ok, Node.t()} | {:error, term}
  defp send_next_available_id(%Packet{}, state) do
    {:ok, node} = Context.new_node()
    Logger.debug("New node: #{node.id}")

    packet_opts = [
      node_id: @internal_BROADCAST_ADDRESS,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      command: @command_INTERNAL,
      type: @internal_ID_RESPONSE,
      ack: @ack_FALSE,
      payload: node.id
    ]

    send_packet = struct(Packet, packet_opts)
    res = do_write(state, send_packet)

    if Enum.all?(res, &match?(:ok, &1)) do
      {:ok, node}
    else
      {:error, :failed_to_send}
    end
  end

  defp do_write(state, packet) do
    for %{module: tp, pid: pid} <- state.transports do
      tp.write(pid, packet)
    end
  end

  defp start_global_heart_timer() do
    Process.send_after(self(), {@internal_HEARTBEAT_REQUEST, :global}, @heart_global_timeout_ms)
  end

  defp maybe_cancel_heart_timer(state, id) do
    state.hearts[id] && Process.cancel_timer(state.hearts[id])
    %{state | hearts: Map.delete(state.hearts, id)}
  end

  defp maybe_start_heart_timer(state, id) do
    state.hearts[id] && Process.cancel_timer(state.hearts[id])
    _ = do_write(state, heart_packet(id))
    ref = Process.send_after(self(), {@internal_HEARTBEAT_REQUEST, id}, @heart_timeout_ms)
    %{state | hearts: Map.put(state.hearts, id, ref)}
  end

  defp heart_packet(id) do
    %Packet{
      ack: false,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      command: @command_INTERNAL,
      node_id: id,
      payload: "",
      type: @internal_HEARTBEAT_REQUEST
    }
  end
end
