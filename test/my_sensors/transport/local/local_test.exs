defmodule MySensors.Transport.LocalTest do
  use ExUnit.Case, async: false

  alias MySensors.{Packet, Gateway}
  use Packet.Constants
  alias MySensors.Transport.Local

  test "recieves dispatched packets" do
    Gateway.add_transport(Local, [])
    packet = %Packet{
      node_id: @internal_BROADCAST_ADDRESS,
      child_sensor_id: @internal_NODE_SENSOR_ID,
      ack: false,
      command: @command_INTERNAL,
      type: @internal_TIME,
      payload: ""
    }
    :ok = Local.register(self())
    :ok = Local.dispatch(packet)
    assert_receive %Packet{
      ack: false,
      child_sensor_id: 255,
      command: :command_internal,
      node_id: 255,
      payload: _,
      type: :internal_time
    }
    Local.stop()
  end
end
