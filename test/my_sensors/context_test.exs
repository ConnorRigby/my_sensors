defmodule MySensors.ContextTest do
  @moduledoc "Tests db actions"

  alias MySensors
  alias MySensors.{Context, Node, Sensor, SensorValue, Packet}

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
end
