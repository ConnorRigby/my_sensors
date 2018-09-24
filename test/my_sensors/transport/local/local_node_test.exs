# defmodule MySensors.Gateway.Local.LocalNodeTest do
#   use ExUnit.Case, async: false
#   alias MySensors.{Packet, Gateway, Context, Broadcast}
#   use Packet.Constants
#   alias MySensors.Transport.Local
#   alias Local.LocalNode

#   alias MySensors.{Packet, Gateway, Context, Broadcast}
#   alias MySensors.Transport.Local
#   alias Local.LocalNode

#   @tag timeout: :infinity

#   setup_all do
#     Gateway.add_transport(Local, [])
#     {:ok, []}
#   end

#   test "starts a local node" do
#     {:ok, local_node} = LocalNode.start_link(nil, delete_on_exit: true)
#     id = :sys.get_state(local_node).node.id
#     assert id
#     Broadcast.subscribe()
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     LocalNode.stop(local_node)
#     refute Context.get_node(id)
#     # Local.stop()
#   end

#   test "Starts a node from an existing node" do
#     node = Context.new_node()
#     {:ok, local_node} = LocalNode.start_link(node, delete_on_exit: true)
#     id = :sys.get_state(local_node).node.id
#     assert id
#     Broadcast.subscribe()
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     LocalNode.stop(local_node)
#     refute Context.get_node(id)
#     # Local.stop()
#   end

#   test "adds a fake sensor to a fake node" do
#     {:ok, local_node} = LocalNode.start_link(nil, [])
#     Broadcast.subscribe()
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000

#     :ok = LocalNode.add_sensor(local_node, @sensor_DOOR)
#   end

#   test "deleting a node stops a localnode" do
#     Process.flag(:trap_exit, true)
#     node = Context.new_node()
#     {:ok, local_node} = LocalNode.start_link(node, [])
#     Broadcast.subscribe()
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000
#     assert_receive {:my_sensors, {:insert_or_update, %MySensors.Node{}}}, 2000

#     got = Context.get_node(node.id)
#     assert got
#     Context.delete_node(node.id)
#     assert_receive {:EXIT, ^local_node, :deleted}, 2000
#   end
# end
