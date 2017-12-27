defmodule MySensors.Transport.Local.LocalNode do
  @moduledoc "Fake Node that operates on the `Local` Transport."

  use GenServer
  alias MySensors.{Context, Broadcast, Packet, Node, Sensor}
  use Packet.Constants
  alias MySensors.Transport.Local
  require Logger

  @app_version Mix.Project.config[:version]

  @doc """
  Start a fake node.
  opts can contain:
    * `sketch_name` - Defaults to a Pokemon name.
    * `sketch_version` -  Defaults to #{@app_version}
  """
  def start_link(node \\ nil, opts \\ []) do
    GenServer.start_link(__MODULE__, [node, opts], [])
  end

  @doc "Stop a node."
  def stop(pid, reason \\ :normal) do
    GenServer.stop(pid, reason)
  end

  @doc "Add a sensor to a node."
  def add_sensor(pid, type) do
    GenServer.call(pid, {:add_sensor, type})
  end

  def init([node, opts]) do
    Local.register(self())
    Broadcast.subscribe(self())
    if node do
      # We already have an id and whatnot.
      # Nothing to do, but broadcast.
      packet = %Packet{
        node_id: @internal_NODE_SENSOR_ID,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_ID_RESPONSE,
        ack: false,
        payload: node.id}
      send self(), packet
    else
      # No id, do we will need to get one.
      id_request = %Packet{
        node_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_ID_REQUEST
      } |> Local.dispatch()
    end
    finish_init([node, opts])
  end

  defp finish_init([node, opts]) do
    receive do
      %Packet{type: @internal_ID_RESPONSE, payload: id} ->
        %Node{} = node = node || Context.get_node(id)
        send self(), :sketch_name_and_version
        {:ok, %{node: node, opts: opts}}
      _ -> finish_init([node, opts])
    after
      5_000 ->
        {:stop, :failed_to_get_id}
    end
  end

  def terminate(reason, state) do
    if reason not in [:shutdown, :normal] do
      Logger.warn "Local node stopping: #{inspect reason}"
    end
    if Keyword.get(state.opts, :delete_on_exit) && state.node do
      Context.delete_node(state.node.id)
    end
  end

  def handle_call({:add_sensor, type}, _, state) do
    node = state.node
    next_sensor_id = Enum.count(node.sensors) + 1
    sensor = %Sensor{
      type: type,
      child_sensor_id: next_sensor_id
    }
    new_node = %{node | sensors: node.sensors ++ [sensor]}
    send self(), :present_sensors
    {:reply, :ok, %{state | node: new_node}}
  end

  def handle_info(:sketch_name_and_version, state) do

    # Broadcast sketch name.
    %Packet{
      command: @command_INTERNAL,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      type: @internal_SKETCH_NAME,
      node_id: state.node.id,
      ack: false,
      payload: Keyword.get(state.opts, :sketch_name, Faker.Pokemon.name)
    } |> Local.dispatch()

    # Broadcast sketch version.
    %Packet{
      command: @command_INTERNAL,
      type: @internal_SKETCH_VERSION,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      node_id: state.node.id,
      ack: false,
      payload: Keyword.get(state.opts, :sketch_version, @app_version)
    } |> Local.dispatch()

    send self(), :present_sensors
    {:noreply, state}
  end

  def handle_info(:present_sensors, state) do
    # Present sensor type and protocol.
    %Packet{
      node_id: state.node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      command: @command_PRESENTATION,
      ack: false,
      type: @sensor_ARDUINO_REPEATER_NODE,
      payload: to_string(__MODULE__)
    } |> Local.dispatch()

    # Present sensors.
    for sensor <- state.node.sensors do
      # Don't broadcast the sensor type and protocol again.
      unless sensor.child_sensor_id == @internal_NODE_SENSOR_ID do
        %Packet{
          node_id: state.node.id,
          child_sensor_id: sensor.child_sensor_id,
          command: @command_PRESENTATION,
          ack: false,
          type: sensor.type,
          payload: ""
        } |> Local.dispatch()
      end
    end
    {:noreply, state}
  end

  def handle_info({:my_sensors, {:delete, %Node{} = node}}, state) do
    if state.node.id == node.id do
      {:stop, :deleted, %{state | node: nil}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:my_sensors, {:insert_or_update, %Node{} = node}}, state) do
    if state.node.id == node.id do
      {:noreply, %{state | node: node}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:my_sensors, {_, _}}, state) do
    {:noreply, state}
  end

  # Ignore packets to different nodes.
  def handle_info(%Packet{node_id: packet_node_id}, %{node: %{id: this_node_id}} = state)
    when packet_node_id != this_node_id
  do
    {:noreply, state}
  end

  def handle_info(%Packet{command: command} = packet, state) when command in [@command_SET, @command_REQ] do
    %Packet{
      node_id: state.node.id,
      child_sensor_id: packet.child_sensor_id,
      command: packet.command,
      type: packet.type,
      ack: false,
      payload: packet.payload
    } |> Local.dispatch
    {:noreply, state}
  end

  def handle_info(%Packet{} = packet, state) do
    Logger.info "Unhandled packet: #{inspect packet} on node: #{inspect state.node}"
    {:noreply, state}
  end

end
