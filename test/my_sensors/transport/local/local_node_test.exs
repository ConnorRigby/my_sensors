defmodule MySensors.Gateway.Local.LocalNodeTest do
  use ExUnit.Case, async: false
  alias MySensors.{Packet, Gateway, Context, Broadcast}
  use Packet.Constants
  alias MySensors.Transport.Local
  alias Local.LocalNode

  setup do
    Gateway.add_transport(Local, [])
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MySensors.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MySensors.Repo, :auto)

    # :ok = Ecto.Adapters.SQL.Sandbox.mode(MySensors.Repo, {:shared, self()})
    {:ok, []}
  end

  test "starts a local node" do
    {:ok, local_node} = LocalNode.start_link(nil, [delete_on_exit: true])
    id = :sys.get_state(local_node).node.id
    assert id
    Broadcast.subscribe(self())
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{}}}, 1000
    LocalNode.stop(local_node)
    refute Context.get_node(id)
    Local.stop()
  end

  test "Starts a node from an existing node" do
    node = Context.new_node()
    {:ok, local_node} = LocalNode.start_link(node, [delete_on_exit: true])
    id = :sys.get_state(local_node).node.id
    assert id
    Broadcast.subscribe(self())
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{}}}, 1000
    LocalNode.stop(local_node)
    refute Context.get_node(id)
    Local.stop()
  end

  test "adds a fake sensor to a fake node" do
    {:ok, local_node} = LocalNode.start_link(nil, [])
    Broadcast.subscribe(self())
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{}}}, 1000

    :ok = LocalNode.add_sensor(local_node, @sensor_DOOR)
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{type: "sensor_door"}}}, 1000
  end

  test "deleting a node stops a localnode" do
    Process.flag(:trap_exit, true)
    node = Context.new_node()
    {:ok, local_node} = LocalNode.start_link(node, [])
    Broadcast.subscribe(self())
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 1000
    assert_receive {:my_sensors, {:insert_or_update, %MySensors.Sensor{}}}, 1000

    got = Context.get_node(node.id)
    assert got
    Context.delete_node(node.id)
    assert_receive {:EXIT, ^local_node, :deleted}, 1000
  end

end
