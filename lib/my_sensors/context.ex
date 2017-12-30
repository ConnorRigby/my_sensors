defmodule MySensors.Context do
  @moduledoc "Repo Context for MySensors"

  alias MySensors.{Broadcast, Packet, Repo, Node, Sensor, SensorValue}
  require Logger

  @doc "Get a node by id."
  @spec get_node(integer) :: Node.t | nil
  def get_node(id), do: {:error, :not_implemented}

  @doc "Delete a node by id."
  def delete_node(id), do: {:error, :not_implemented}

  @doc "Get all nodes."
  @spec all_nodes :: [Node.t]
  def all_nodes, do: {:error, :not_implemented}

  @doc "Get a nenw node."
  @spec new_node :: Node.t
  def new_node, do: {:error, :not_implemented}

  @doc "Updata a node."
  @spec update_node(Node.t, map) :: {:ok, Node.t} | {:error, term}
  def update_node(node, params), do: {:error, :not_implemented}

  @doc "Saves the protocol of a node from a packet"
  @spec save_protocol(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_protocol(%Packet{} = packet), do: {:error, :not_implemented}

  @doc "Save the config of a node from a packet."
  @spec save_config(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_config(%Packet{node_id: node_id, payload: config}), do: {:error, :not_implemented}

  @doc "Save a node's battery_level"
  @spec save_battery_level(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_battery_level(%Packet{} = packet), do: {:error, :not_implemented}

  @doc "Save a node's sketch_name"
  @spec save_sketch_name(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_sketch_name(%Packet{} = packet), do: {:error, :not_implemented}

  @doc "Save a node's sketch_version"
  @spec save_sketch_version(Packet.t) :: {:ok, Node.t} | {:error, term}
  def save_sketch_version(%Packet{} = packet), do: {:error, :not_implemented}

  @doc "Save a sensor on a node."
  @spec save_sensor(Packet.t) :: {:ok, Sensor.t} | {:error, term}
  def save_sensor(%Packet{node_id: node_id, child_sensor_id: sid} = packet), do: {:error, :not_implemented}

  @doc "Save a sensor_value from a sensor."
  @spec save_sensor_value(Packet.t) :: {:ok, SensorValue.t} | {:error, term}
  def save_sensor_value(%Packet{} = packet), do: {:error, :not_implemented}

  @doc "Get a sensor from node_id and sensor_id"
  @spec get_sensor(integer, integer) :: Sensor.t | nil
  def get_sensor(node_id, child_sensor_id), do: {:error, :not_implemented}

  @doc "Get all sensors."
  @spec all_sensors(integer) :: [Sensor.t] | nil
  def all_sensors(node_id), do: {:error, :not_implemented}
end
