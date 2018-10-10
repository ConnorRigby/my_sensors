defmodule MySensors.Context do
  @moduledoc "Repo Context for MySensors"

  alias MySensors.{Context, Repo, Packet, Node, Sensor, SensorValue}
  use Packet.Constants
  require Logger
  import Ecto.Query, warn: false

  @doc "Get a node by id."
  @spec get_node(integer) :: Node.t() | nil
  def get_node(id) do
    Repo.get(Node, id)
    |> Repo.preload(:sensors)
  end

  @spec get_id_status(integer) :: Node.t() | {:error, :no_node}
  def get_id_status(id) do
    Repo.one(from(n in Node, where: n.id == ^id, select: n.status)) || {:error, :no_node}
  end

  @spec set_id_status(integer, String.t()) :: {:ok, Node.t()} | {:error, term}
  def set_id_status(id, status) do
    with %Node{} = node <- get_node(id) do
      update_node(node, %{status: status})
    else
      nil -> {:error, :no_node}
    end
  end

  @doc "Delete a node by id."
  def delete_node(id) do
    with %Node{} = node <- Context.get_node(id) do
      Repo.delete(node)
      |> do_dispatch(:delete)
    end
  end

  @doc "Get all nodes."
  @spec all_nodes :: [Node.t()]
  def all_nodes do
    MySensors.Repo.all(from(n in MySensors.Node, preload: :sensors))
  end

  @doc "Get a nenw node."
  @spec new_node(map) :: {:ok, Node.t()} | {:error, term}
  def new_node(params \\ %{}) do
    %Node{}
    |> Node.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, node} ->
        {:ok, Repo.preload(node, :sensors)}

      {:error, _} = error ->
        error
    end
    |> do_dispatch(:insert_or_update)
  end

  @doc "Updata a node."
  @spec update_node(Node.t(), map) :: {:ok, Node.t()} | {:error, term}
  def update_node(%Node{} = node, params) do
    node
    |> Node.changeset(params)
    |> Repo.update()
    |> do_dispatch(:insert_or_update)
  end

  def save_node(%Packet{node_id: node_id}) when node_id > 0 do
    with {:ok, %Node{} = node} <- set_id_status(node_id, "ok") do
      {:ok, node}
    else
      _ -> new_node(%{id: node_id})
    end
  end

  @doc "Saves the protocol of a node from a packet"
  @spec save_protocol(Packet.t()) :: {:ok, Node.t()} | {:error, term}
  def save_protocol(%Packet{
        node_id: node_id,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_PRESENTATION,
        payload: protocol
      }) do
    case get_node(node_id) do
      %Node{} = node -> update_node(node, %{protocol: protocol})
      nil -> new_node(%{id: node_id, protocol: protocol})
    end
  end

  def save_protocol(%Packet{}), do: {:error, :bad_packet}

  @doc "Save the config of a node from a packet."
  @spec save_config(Packet.t()) :: {:ok, Node.t()} | {:error, term}
  def save_config(%Packet{
        node_id: node_id,
        payload: config,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_CONFIG
      }) do
    case get_node(node_id) do
      %Node{} = node -> update_node(node, %{config: config})
      nil -> new_node(%{id: node_id, config: config})
    end
  end

  @doc "Save a node's battery_level"
  @spec save_battery_level(Packet.t()) :: {:ok, Node.t()} | {:error, term}
  def save_battery_level(%Packet{
        node_id: node_id,
        payload: value,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_BATTERY_LEVEL
      }) do
    case Float.parse(to_string(value)) do
      :error ->
        {:error, :bad_battery_level}

      {battery_level, _} ->
        case get_node(node_id) do
          %Node{} = node ->
            update_node(node, %{battery_level: battery_level})

          nil ->
            new_node(%{id: node_id, battery_level: battery_level})
        end
    end
  end

  @doc "Save a node's sketch_name"
  @spec save_sketch_name(Packet.t()) :: {:ok, Node.t()} | {:error, term}
  def save_sketch_name(%Packet{
        node_id: node_id,
        payload: sketch_name,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_SKETCH_NAME
      }) do
    case get_node(node_id) do
      %Node{} = node ->
        update_node(node, %{sketch_name: sketch_name})

      nil ->
        new_node(%{id: node_id, sketch_name: sketch_name})
    end
  end

  @doc "Save a node's sketch_version"
  @spec save_sketch_version(Packet.t()) :: {:ok, Node.t()} | {:error, term}
  def save_sketch_version(%Packet{
        node_id: node_id,
        payload: sketch_version,
        child_sensor_id: @internal_NODE_SENSOR_ID,
        command: @command_INTERNAL,
        type: @internal_SKETCH_VERSION
      }) do
    case get_node(node_id) do
      %Node{} = node ->
        update_node(node, %{sketch_version: sketch_version})

      nil ->
        new_node(%{id: node_id, sketch_version: sketch_version})
    end
  end

  @doc "Save a sensor on a node."
  @spec save_sensor(Packet.t()) :: {:ok, Sensor.t()} | {:error, term}
  def save_sensor(%Packet{
        node_id: node_id,
        child_sensor_id: sid,
        type: type,
        command: @command_PRESENTATION
      }) do
    case get_sensor(node_id, sid) do
      %Sensor{} = sensor ->
        update_sensor(sensor, %{type: to_string(type)})

      nil ->
        case get_node(node_id) do
          nil ->
            {:ok, node} = new_node(%{id: node_id})
            node

          %Node{} = node ->
            node
        end
        |> Ecto.build_assoc(:sensors)
        |> Sensor.changeset(%{child_sensor_id: sid, type: to_string(type)})
        |> Repo.insert()
        |> do_dispatch(:insert_or_update)
    end
  end

  @doc "Save a sensor_value from a sensor."
  @spec save_sensor_value(Packet.t()) :: {:ok, SensorValue.t()} | {:error, term}
  def save_sensor_value(%Packet{
        node_id: node_id,
        child_sensor_id: sid,
        type: type,
        payload: payload,
        command: @command_SET
      }) do
    {value, _} = Float.parse(payload)

    case get_sensor(node_id, sid) do
      %Sensor{} = sensor ->
        sensor

      nil ->
        pkt = %Packet{
          node_id: node_id,
          ack: false,
          payload: "",
          child_sensor_id: sid,
          type: type,
          command: @command_PRESENTATION
        }

        {:ok, %Sensor{} = sensor} = save_sensor(pkt)
        sensor
    end
    |> Ecto.build_assoc(:sensor_values)
    |> SensorValue.changeset(%{type: to_string(type), value: value})
    |> Repo.insert()
    |> do_dispatch(:insert_or_update)
  end

  @doc "Get a sensor from node_id and sensor_id"
  @spec get_sensor(integer, integer) :: Sensor.t() | nil
  def get_sensor(node_id, child_sensor_id) do
    Repo.one(
      from(s in Sensor, where: s.node_id == ^node_id and s.child_sensor_id == ^child_sensor_id)
    )
  end

  @doc "Get all sensors."
  @spec all_sensors(integer) :: [Sensor.t()] | nil
  def all_sensors(node_id) do
    case get_node(node_id) do
      %Node{sensors: sensors} when is_list(sensors) -> sensors
      nil -> nil
    end
  end

  def all_sensor_values(node_id, child_sensor_id) do
    case get_sensor(node_id, child_sensor_id) do
      %Sensor{} = sensor ->
        Repo.preload(sensor, :sensor_values)
        |> Map.get(:sensor_values)

      e ->
        e
    end
  end

  def update_sensor(%Sensor{} = sensor, params) do
    case get_node(sensor.node_id) do
      %Node{} = node ->
        node

      nil ->
        {:ok, node} = new_node(%{id: sensor.node_id})
        node
    end
    |> Ecto.build_assoc(:sensors, sensor)
    |> Sensor.changeset(params)
    |> Repo.update()
    |> do_dispatch(:insert_or_update)
  end

  defp do_dispatch({:error, _} = data, _) do
    data
  end

  defp do_dispatch({:ok, data} = val, kind) do
    MySensors.Broadcast.dispatch({kind, data})
    val
  end

  defp do_dispatch(data, kind) do
    MySensors.Broadcast.dispatch({kind, data})
    data
  end
end
