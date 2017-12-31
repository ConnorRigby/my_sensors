defmodule MySensors.Context do
  @moduledoc "Repo Context for MySensors"

  alias MySensors.{Packet, Node, Sensor, SensorValue}
  use Packet.Constants
  require Logger

  @doc "Get a node by id."
  @spec get_node(integer) :: Node.t | nil
  def get_node(id) do
    res = :mnesia.transaction fn() -> :mnesia.read(Node, id) end
    case res do
      {:atomic, [record]} -> Node.to_struct(record)
      {:atomic, []} -> nil
    end
  end

  @doc "Delete a node by id."
  def delete_node(id) do
    case :mnesia.transaction fn -> :mnesia.delete({Node, id}) end do
      {:atomic, :ok} -> :ok
    end
  end

  @doc "Get all nodes."
  @spec all_nodes :: [Node.t]
  def all_nodes do
    case :mnesia.transaction fn -> :mnesia.all_keys(Node) end do
      {:atomic, ids} -> Enum.map(ids, &get_node(&1))
      err -> err
    end
  end

  @doc "Get a nenw node."
  @spec new_node :: Node.t
  def new_node do
    id = case :mnesia.transaction fn -> :mnesia.last(Node) end do
      {:atomic, :"$end_of_table"} -> 0
      {:atomic, id} -> id
    end

    new_node = struct(Node, [id: id + 1])
    fun = fn -> :mnesia.write(Node.from_struct(new_node)) end
    case :mnesia.transaction(fun) do
      {:atomic, :ok} -> new_node
      err -> err
    end
  end

  @doc "Updata a node."
  @spec update_node(Node.t, map) :: {:ok, Node.t} | {:error, term}
  def update_node(node, params) do
    params = Map.new(params)
    map = Map.take(params, Node.keys())
    new_node = Map.merge(node, map)
    record = Node.from_struct(new_node)
    case :mnesia.transaction fn -> :mnesia.write(record) end do
      {:atomic, :ok} -> {:ok, new_node}
      err -> err
    end
  end

  @doc "Saves the protocol of a node from a packet"
  @spec save_protocol(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_protocol(%Packet{
    node_id: node_id,
    child_sensor_id: @internal_NODE_SENSOR_ID,
    command: @command_PRESENTATION,
    payload: protocol
  }) do
    case get_node(node_id) do
      %Node{} = node -> update_node(node, %{protocol: protocol})
      nil -> {:error, :no_node}
    end
  end

  def save_protocol(%Packet{}), do: {:error, :bad_packet}

  @doc "Save the config of a node from a packet."
  @spec save_config(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_config(%Packet{
    node_id: node_id, payload: config,
    child_sensor_id: @internal_NODE_SENSOR_ID,
    command: @command_INTERNAL, type: @internal_CONFIG
  }) do
    case get_node(node_id) do
      %Node{} = node -> update_node(node, %{config: config})
      nil -> {:error, :no_node}
    end
  end

  @doc "Save a node's battery_level"
  @spec save_battery_level(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_battery_level(%Packet{
    node_id: node_id, payload: value,
    child_sensor_id: @internal_NODE_SENSOR_ID,
    command: @command_INTERNAL, type: @internal_BATTERY_LEVEL
  }) do
    case Float.parse(to_string(value)) do
      :error -> {:error, :bad_battery_level}
      {battery_level, _} ->
        case get_node(node_id) do
          %Node{} = node ->
            update_node(node, %{battery_level: battery_level})
          nil ->
            {:error, :no_node}
        end
    end
  end

  @doc "Save a node's sketch_name"
  @spec save_sketch_name(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_sketch_name(%Packet{
    node_id: node_id, payload: sketch_name,
    child_sensor_id: @internal_NODE_SENSOR_ID,
    command: @command_INTERNAL, type: @internal_SKETCH_NAME
  }) do
    case get_node(node_id) do
      %Node{} = node ->
        update_node(node, %{sketch_name: sketch_name})
      nil ->
        {:error, :no_node}
    end
  end

  @doc "Save a node's sketch_version"
  @spec save_sketch_version(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_sketch_version(%Packet{
    node_id: node_id, payload: sketch_version,
    child_sensor_id: @internal_NODE_SENSOR_ID,
    command: @command_INTERNAL, type: @internal_SKETCH_VERSION
  }) do
    case get_node(node_id) do
      %Node{} = node ->
        update_node(node, %{sketch_version: sketch_version})
      nil ->
        {:error, :no_node}
    end
  end

  @doc "Save a sensor on a node."
  @spec save_sensor(Packet.t) :: {:ok, Sensor.t} | {:error, term}
  def save_sensor(%Packet{
    node_id: node_id, child_sensor_id: sid, type: type,
    command: @command_PRESENTATION
  }) do
    case get_sensor(node_id, sid) do
      %Sensor{} = sensor -> update_sensor(sensor, %{type: type})
      nil ->
        case get_node(node_id) do
          nil -> {:error, :no_node}
          %Node{} = node ->
            sensor = struct(Sensor, [child_sensor_id: sid, node_id: node_id, type: to_string(type), sensor_values: []])
            new_sensors = node.sensors ++ [sensor]
            case update_node(node, sensors: new_sensors) do
              {:ok, %Node{}} -> {:ok, sensor}
              err -> err
            end
        end
    end
  end

  @doc "Save a sensor_value from a sensor."
  @spec save_sensor_value(Packet.t) :: {:ok, SensorValue.t} | {:error, term}
  def save_sensor_value(%Packet{
    node_id: node_id, child_sensor_id: sid, type: type, payload: payload,
    command: @command_SET
  }) do
    case get_sensor(node_id, sid) do
      %Sensor{} = sensor ->
        {value, _} = Float.parse(payload)
        sv = struct(SensorValue, [sensor_id: sid, type: to_string(type), value: value])
        new_sensor_values = sensor.sensor_values ++ [sv]
        case update_sensor(sensor, [sensor_values: new_sensor_values]) do
          {:ok, %Sensor{}} -> {:ok, sv}
          err -> err
        end
      nil -> {:error, :no_sensor}
    end
  end

  @doc "Get a sensor from node_id and sensor_id"
  @spec get_sensor(integer, integer) :: Sensor.t | nil
  def get_sensor(node_id, child_sensor_id) do
    case all_sensors(node_id) do
      sensors when is_list(sensors) ->
        Enum.find(sensors || [], fn(%Sensor{child_sensor_id: sid}) ->
          child_sensor_id == sid
        end)
      nil -> nil
    end
  end

  @doc "Get all sensors."
  @spec all_sensors(integer) :: [Sensor.t] | nil
  def all_sensors(node_id) do
    case get_node(node_id) do
      %Node{sensors: sensors} -> sensors || []
      nil -> nil
    end
  end

  def update_sensor(%Sensor{} = sensor, params) do
    params = Map.new(params)
    map = Map.take(params, Sensor.keys())
    new_sensor = Map.merge(sensor, map)
    case get_node(sensor.node_id) do
      %Node{} = node ->
        new_sensors = Enum.map(node.sensors || [], fn(%Sensor{} = s_sensor) ->
          if s_sensor.child_sensor_id == sensor.child_sensor_id do
            new_sensor
          else
            s_sensor
          end
        end)
        case update_node(node, %{sensors: new_sensors}) do
          {:ok, %Node{}} -> {:ok, new_sensor}
          err -> err
        end
      nil -> {:error, :no_node}
    end
  end
end
