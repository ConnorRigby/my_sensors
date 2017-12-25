defmodule MySensors.Web.LanApp.ResourceSocket do
  @moduledoc """
  Lan App WebSocket Server for MySensors Resources.
  On initialization, this module subscribes to [MySensors.Broadcast]("MySensors.Broadcast.html").
  Sends out JSON resources over the socket.

  Example:
    <script>
      var socket = new WebSocket("ws://localhost:4001/ws");
      socket.onmessage = function(event) {
        var data = JSON.parse(event.data);
        /*
        Data will be a object:
        {
          action: "insert_or_update",
          resource: {node_id: 1, sketch_name: "some sensor"}
        }
        */
      };
    </script>
  """
  alias MySensors.Broadcast
  require Logger

  def init(_, _req, _opts), do: {:upgrade, :protocol, :cowboy_websocket}

  def websocket_init(_type, req, _options) do
    Logger.debug "resource socket open"
    Broadcast.subscribe(self())
    {:ok, req, %{}, :infinity}
  end

  # messages from the browser.
  def websocket_handle({:text, _m}, req, state) do
    {:ok, req, state}
  end

  def websocket_info({:my_sensors, {action, resource}}, req, state) do
    data = Poison.encode!(%{"action" => action, "resource" => resource})
    {:reply, {:text, data}, req, state}
  end

  def websocket_terminate(_, _, _) do
    Logger.debug "resource socket closing."
  end
end
