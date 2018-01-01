[![CircleCI](https://circleci.com/gh/ConnorRigby/my_sensors.svg?style=svg)](https://circleci.com/gh/ConnorRigby/my_sensors)
[![Coverage Status](https://coveralls.io/repos/github/ConnorRigby/my_sensors/badge.svg?branch=master)](https://coveralls.io/github/ConnorRigby/my_sensors?branch=master)

# MySensors

## Usage

The [package](https://hex.pm/packages/my_sensors) can be installed by adding `my_sensors` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:my_sensors, "~> 0.1.0-rc2"}
  ]
end
```

Then add a transport to the Gateway. By default you have two options:
## UART
To use the UART transport, first wire up and flash your arduino according to the
[MySensors Serial Gateway Instructions](https://www.mysensors.org/build/serial_gateway).
then you can start the gateway with:
```elixir
MySensors.add_gateway(MySensors.Transport.UART, [device: "/dev/devicePath"])
```

## TCP
to use the TCP transport, first wire up and flash your arduino according to the
[MySensors Ethernet Gateway Instructions](https://www.mysensors.org/build/ethernet_gateway).
(Or you can use the [MySensors WiFi Gateway](https://www.mysensors.org/build/esp8266_gateway).)
then you can start the gateway with:
```elixir
MySensors.add_gateway(MySensors.Transpoart.TCP, [host: {192, 168, 1, 40}, port: 5001])
```
Make sure you use the correct host. You can use local hostnames also, if resolvable.
