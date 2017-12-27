defmodule MySensors.ContextTest do
  @moduledoc "Tests db actions"

  alias MySensors
  alias MySensors.{Context, Node, Sensor, SensorValue, Packet}
  use Packet.Constants

  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MySensors.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(MySensors.Repo, {:shared, self()})
  end

  test "Generates nodes" do
    node_b = Context.new_node()
    node_a = Context.new_node()
    assert match?(%Node{}, node_a)
    assert match?(%Node{}, node_b)

    refute match?(^node_a, node_b)
  end

  test "Lists all nodes" do
    Context.new_node()
    Context.new_node()
    all_nodes = Context.all_nodes
    assert Enum.count(all_nodes) >= 2
  end

  test "saves config from a packet" do
    node = Context.new_node()
    packet = %Packet{node_id: node.id,
                     child_sensor_id: 255,
                     payload: "M",
                     command: @command_INTERNAL,
                     ack: false,
                     type: :internal_CONFIG}
    {:ok, %Node{} = node} = Context.save_config(packet)
    assert node.config == "M"
    assert Context.get_node(node.id).config == "M"
  end

  test "saves protocol from a packet" do
    node = Context.new_node()
    packet = %Packet{node_id: node.id,
                     child_sensor_id: 255,
                     payload: "Some cool protocol",
                     command: :command_PRESENTATION,
                     type: :sensor_ARDUINO_NODE}
    {:ok, %Node{} = node} = Context.save_protocol(packet)
    assert node.protocol == "Some cool protocol"
    assert Context.get_node(node.id).protocol == "Some cool protocol"
  end

  test "saves battery level from a packet" do
    node = Context.new_node()
    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 255,
      payload: 95,
      ack: false,
      command: @command_INTERNAL,
      type: :internal_BATTERY
    }
    {:ok, %Node{} = node} = Context.save_battery_level(packet)
    assert node.battery_level == 95
    assert Context.get_node(node.id).battery_level == 95
  end

  test "saves a node sketch name from a packet" do
    node = Context.new_node()
    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 255,
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
    node = Context.new_node()
    packet = %Packet{
      node_id: node.id,
      child_sensor_id: 255,
      payload: "2.4.3",
      ack: false,
      command: @command_INTERNAL,
      type: @internal_SKETCH_NAME
    }
    {:ok, %Node{} = node} = Context.save_sketch_version(packet)
    assert node.sketch_version == "2.4.3"
    assert Context.get_node(node.id).sketch_version == "2.4.3"
  end
end
