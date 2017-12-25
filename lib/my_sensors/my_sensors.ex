defmodule MySensors do
  @moduledoc """
  The `MySensors` part of the app has a few parts:
  * [Packet](MySensors.Packet) - An Elixir Parsed packet.
  * [Gateway](MySensors.Gateway.html) - Handles parsed Packets.
    * [Gateway.Transport](MySensors.Gateway.Transport.html) -
    A GenStage behaviour for `Transport`s to implement.
      * [UART Transport](MySensors.Transport.UART.html) ->
      A transport to a `serial_gateway` sketch.
      * [TCP Transport](MySensors.Transport.GenTCP.html) ->
      A transport to a `ethernet_gateway` sketch.
  * [Repo](MySensors.Repo.html) - Database to store
  [Node](MySensors.Node.html),
  [Sensor](MySensors.Sensor.html),
  and [SensorValue](MySensors.SensorValue.html) data.
  """
end
