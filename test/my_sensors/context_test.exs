defmodule MySensors.ContextTest do
  @moduledoc "Tests db actions"

  alias MySensors
  alias MySensors.{Context, Node, Sensor, SensorValue, Packet}
  use Packet.Constants

  use ExUnit.Case, async: false

  test "Generates nodes" do
    node_b = Context.new_node()
    node_a = Context.new_node()
    assert match?({:ok, %Node{}}, node_a)
    assert match?({:ok, %Node{}}, node_b)

    refute match?(^node_a, node_b)
  end

  test "Lists all nodes" do
    Context.new_node()
    Context.new_node()
    all_nodes = Context.all_nodes()
    assert Enum.count(all_nodes) >= 2
  end

  test "saves config from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      payload: "M",
      command: @command_INTERNAL,
      ack: false,
      type: @internal_CONFIG
    }

    {:ok, %Node{} = node} = Context.save_config(packet)
    assert node.config == "M"
    assert Context.get_node(node.id).config == "M"
  end

  test "saves protocol from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      payload: "Some cool protocol",
      command: @command_PRESENTATION,
      type: @sensor_ARDUINO_NODE
    }

    {:ok, %Node{} = node} = Context.save_protocol(packet)
    assert node.protocol == "Some cool protocol"
    assert Context.get_node(node.id).protocol == "Some cool protocol"
  end

  test "saves battery level from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      payload: 95,
      ack: false,
      command: @command_INTERNAL,
      type: @internal_BATTERY_LEVEL
    }

    {:ok, %Node{} = node} = Context.save_battery_level(packet)
    assert node.battery_level == 95
    assert Context.get_node(node.id).battery_level == 95
  end

  test "saves a node sketch name from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      payload: "some cool sketch",
      ack: false,
      command: @command_INTERNAL,
      type: @internal_SKETCH_NAME
    }

    {:ok, %Node{} = node} = Context.save_sketch_name(packet)
    assert node.sketch_name == "some cool sketch"
    assert Context.get_node(node.id).sketch_name == "some cool sketch"
  end

  test "saves a node sketch version from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      payload: "2.4.3",
      ack: false,
      command: @command_INTERNAL,
      type: @internal_SKETCH_VERSION
    }

    {:ok, %Node{} = node} = Context.save_sketch_version(packet)
    assert node.sketch_version == "2.4.3"
    assert Context.get_node(node.id).sketch_version == "2.4.3"
  end

  test "saves a sensor from a packet" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 5,
      ack: false,
      command: @command_PRESENTATION,
      type: @sensor_BINARY,
      payload: ""
    }

    {:ok, %Sensor{} = sensor} = Context.save_sensor(packet)
    assert sensor.node_id == node.id
    assert sensor.child_sensor_id == 5
  end

  test "saves a sensorvalue to a sensor" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 5,
      ack: false,
      command: @command_PRESENTATION,
      type: @sensor_BINARY,
      payload: ""
    }

    {:ok, %Sensor{} = sensor} = Context.save_sensor(packet)

    sensor_value_packet = %Packet{
      node_id: node.id,
      child_sensor_id: 5,
      ack: false,
      command: @command_SET,
      type: @sensor_BINARY,
      payload: "1"
    }

    {:ok, %SensorValue{} = sv} = Context.save_sensor_value(sensor_value_packet)
    assert sv.sensor_id == sensor.id
    assert sv.value == 1.0
  end

  test "Creates a sensor for a sensor_value if it doesn't exist" do
    {:ok, node} = Context.new_node()

    sensor_value_packet = %Packet{
      node_id: node.id,
      child_sensor_id: 500,
      ack: false,
      command: @command_SET,
      type: @sensor_BINARY,
      payload: "1"
    }

    res = Context.save_sensor_value(sensor_value_packet)
    assert Context.get_sensor(node.id, 500)
    assert match?({:ok, %SensorValue{}}, res)
  end

  test "gets sensors" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 5,
      ack: false,
      command: @command_PRESENTATION,
      type: @sensor_BINARY,
      payload: ""
    }

    {:ok, %Sensor{}} = Context.save_sensor(packet)
    {:ok, %Sensor{}} = Context.save_sensor(%{packet | child_sensor_id: 6, type: @sensor_DOOR})
    {:ok, %Sensor{}} = Context.save_sensor(%{packet | child_sensor_id: 20, type: @sensor_HUM})

    res = Context.all_sensors(node.id)
    assert Enum.count(res) == 3

    assert Context.get_sensor(node.id, 5).node_id == node.id
    assert Context.get_sensor(node.id, 5).type == "sensor_binary"

    assert Context.get_sensor(node.id, 6).node_id == node.id
    assert Context.get_sensor(node.id, 6).type == "sensor_door"

    assert Context.get_sensor(node.id, 20).node_id == node.id
    assert Context.get_sensor(node.id, 20).type == "sensor_hum"
  end

  test "saving a sensor twice doesnt cause duplicates" do
    {:ok, node} = Context.new_node()

    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 5,
      ack: false,
      command: @command_PRESENTATION,
      type: @sensor_BINARY,
      payload: ""
    }

    {:ok, %Sensor{}} = Context.save_sensor(packet)
    {:ok, %Sensor{}} = Context.save_sensor(packet)
    assert Context.get_node(node.id).sensors |> Enum.count() == 1
  end
end
