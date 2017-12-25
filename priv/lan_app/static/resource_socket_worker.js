var socket = new WebSocket("ws://localhost:4001/resource_socket");
socket.onmessage = function(event) {
  var data = JSON.parse(event.data);
  postMessage(data);
};
