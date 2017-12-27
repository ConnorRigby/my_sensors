defmodule MySensors.BroadcastTest do
  alias MySensors.{Context, Broadcast, Node}
  use ExUnit.Case, async: false

  doctest Broadcast

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MySensors.Repo, ownership_timeout: :infinity)
  end

  test "gets node object notifications on update" do
    Broadcast.subscribe(self())
    node = Context.new_node()
    Context.update_node(node, %{sketch_name: "some name"})
    id = node.id
    sketch_name = "some name"
    assert_receive {:my_sensors, {:insert_or_update, %Node{id: id, sketch_name: sketch_name}}}
  end

  test "gets node object notifications on delete" do
    Broadcast.subscribe(self())
    node = Context.new_node()
    id = node.id
    Context.delete_node(id)
    assert_receive {:my_sensors, {:delete, %Node{id: ^id}}}
  end
end
