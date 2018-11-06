defmodule MySensors.Packet do
  @moduledoc """
  MySensors packet.

  Shaped like: `1;2;3;4;5;6` -
  * 1 Packet node_id - Destination node for packet.
    * 0 Will always be the Gateway.
    * 255 is broadcast.
  * 2 Packet sensor_id - Sensor on a particular node.
    * 0 is reserved.
    * 255 is the node_type (ARDUINO_NODE | ARDUINO_REPEATER_NODE)
  * 3 Packet command
    * PRESENTATION
    * SET
    * REQ
    * INTERNAL
    * STREAM
  * 4 Packet ACK
    * 1 is ACK
    * 0 is NOACK
  * 5 Packet type
    * Varies based on Packet Command.
  * 6 Payload
  """
  defstruct [:node_id, :child_sensor_id, :command, :type, :ack, :payload]

  use MySensors.Packet.Constants

  @doc "Parse a packet `command`."
  @compile {:inline, command: 1}
  def command(0), do: {:ok, @command_PRESENTATION}
  def command(1), do: {:ok, @command_SET}
  def command(2), do: {:ok, @command_REQ}
  def command(3), do: {:ok, @command_INTERNAL}
  def command(4), do: {:ok, @command_STREAM}
  def command(@command_PRESENTATION), do: {:ok, 0}
  def command(@command_SET), do: {:ok, 1}
  def command(@command_REQ), do: {:ok, 2}
  def command(@command_INTERNAL), do: {:ok, 3}
  def command(@command_STREAM), do: {:ok, 4}
  def command(_), do: {:error, @command_UNKNOWN}

  @doc "Parse a packet `type` based on a `command`."
  @compile {:inline, type: 2}
  ## PRESENTATION
  def type(@command_PRESENTATION, 0), do: {:ok, @sensor_DOOR}
  def type(@command_PRESENTATION, 1), do: {:ok, @sensor_MOTION}
  def type(@command_PRESENTATION, 2), do: {:ok, @sensor_SMOKE}
  def type(@command_PRESENTATION, 3), do: {:ok, @sensor_BINARY}
  def type(@command_PRESENTATION, 4), do: {:ok, @sensor_DIMMER}
  def type(@command_PRESENTATION, 5), do: {:ok, @sensor_COVER}
  def type(@command_PRESENTATION, 6), do: {:ok, @sensor_TEMP}
  def type(@command_PRESENTATION, 7), do: {:ok, @sensor_HUM}
  def type(@command_PRESENTATION, 8), do: {:ok, @sensor_BARO}
  def type(@command_PRESENTATION, 9), do: {:ok, @sensor_WIND}
  def type(@command_PRESENTATION, 10), do: {:ok, @sensor_RAIN}
  def type(@command_PRESENTATION, 11), do: {:ok, @sensor_UV}
  def type(@command_PRESENTATION, 12), do: {:ok, @sensor_WEIGHT}
  def type(@command_PRESENTATION, 13), do: {:ok, @sensor_POWER}
  def type(@command_PRESENTATION, 14), do: {:ok, @sensor_HEATER}
  def type(@command_PRESENTATION, 15), do: {:ok, @sensor_DISTANCE}
  def type(@command_PRESENTATION, 16), do: {:ok, @sensor_LIGHT_LEVEL}
  def type(@command_PRESENTATION, 17), do: {:ok, @sensor_ARDUINO_NODE}
  def type(@command_PRESENTATION, 18), do: {:ok, @sensor_ARDUINO_REPEATER_NODE}
  def type(@command_PRESENTATION, 19), do: {:ok, @sensor_LOCK}
  def type(@command_PRESENTATION, 20), do: {:ok, @sensor_IR}
  def type(@command_PRESENTATION, 21), do: {:ok, @sensor_WATER}
  def type(@command_PRESENTATION, 22), do: {:ok, @sensor_AIR_QUALITY}
  def type(@command_PRESENTATION, 23), do: {:ok, @sensor_CUSTOM}
  def type(@command_PRESENTATION, 24), do: {:ok, @sensor_DUST}
  def type(@command_PRESENTATION, 25), do: {:ok, @sensor_SCENE_CONTROLLER}
  def type(@command_PRESENTATION, 26), do: {:ok, @sensor_RGB_LIGHT}
  def type(@command_PRESENTATION, 27), do: {:ok, @sensor_RGBW_LIGHT}
  def type(@command_PRESENTATION, 28), do: {:ok, @sensor_COLOR_SENSOR}
  def type(@command_PRESENTATION, 29), do: {:ok, @sensor_HVAC}
  def type(@command_PRESENTATION, 30), do: {:ok, @sensor_MULTIMETER}
  def type(@command_PRESENTATION, 31), do: {:ok, @sensor_SPRINKLER}
  def type(@command_PRESENTATION, 32), do: {:ok, @sensor_WATER_LEAK}
  def type(@command_PRESENTATION, 33), do: {:ok, @sensor_SOUND}
  def type(@command_PRESENTATION, 34), do: {:ok, @sensor_VIBRATION}
  def type(@command_PRESENTATION, 35), do: {:ok, @sensor_MOISTURE}
  def type(@command_PRESENTATION, 36), do: {:ok, @sensor_INFO}
  def type(@command_PRESENTATION, 37), do: {:ok, @sensor_GAS}
  def type(@command_PRESENTATION, 38), do: {:ok, @sensor_GPS}
  def type(@command_PRESENTATION, 39), do: {:ok, @sensor_WATER_QUALITY}

  def type(@command_PRESENTATION, @sensor_DOOR), do: {:ok, 0}
  def type(@command_PRESENTATION, @sensor_MOTION), do: {:ok, 1}
  def type(@command_PRESENTATION, @sensor_SMOKE), do: {:ok, 2}
  def type(@command_PRESENTATION, @sensor_BINARY), do: {:ok, 3}
  def type(@command_PRESENTATION, @sensor_DIMMER), do: {:ok, 4}
  def type(@command_PRESENTATION, @sensor_COVER), do: {:ok, 5}
  def type(@command_PRESENTATION, @sensor_TEMP), do: {:ok, 6}
  def type(@command_PRESENTATION, @sensor_HUM), do: {:ok, 7}
  def type(@command_PRESENTATION, @sensor_BARO), do: {:ok, 8}
  def type(@command_PRESENTATION, @sensor_WIND), do: {:ok, 9}
  def type(@command_PRESENTATION, @sensor_RAIN), do: {:ok, 10}
  def type(@command_PRESENTATION, @sensor_UV), do: {:ok, 11}
  def type(@command_PRESENTATION, @sensor_WEIGHT), do: {:ok, 12}
  def type(@command_PRESENTATION, @sensor_POWER), do: {:ok, 13}
  def type(@command_PRESENTATION, @sensor_HEATER), do: {:ok, 14}
  def type(@command_PRESENTATION, @sensor_DISTANCE), do: {:ok, 15}
  def type(@command_PRESENTATION, @sensor_LIGHT_LEVEL), do: {:ok, 16}
  def type(@command_PRESENTATION, @sensor_ARDUINO_NODE), do: {:ok, 17}
  def type(@command_PRESENTATION, @sensor_ARDUINO_REPEATER_NODE), do: {:ok, 18}
  def type(@command_PRESENTATION, @sensor_LOCK), do: {:ok, 19}
  def type(@command_PRESENTATION, @sensor_IR), do: {:ok, 20}
  def type(@command_PRESENTATION, @sensor_WATER), do: {:ok, 21}
  def type(@command_PRESENTATION, @sensor_AIR_QUALITY), do: {:ok, 22}
  def type(@command_PRESENTATION, @sensor_CUSTOM), do: {:ok, 23}
  def type(@command_PRESENTATION, @sensor_DUST), do: {:ok, 24}
  def type(@command_PRESENTATION, @sensor_SCENE_CONTROLLER), do: {:ok, 25}
  def type(@command_PRESENTATION, @sensor_RGB_LIGHT), do: {:ok, 26}
  def type(@command_PRESENTATION, @sensor_RGBW_LIGHT), do: {:ok, 27}
  def type(@command_PRESENTATION, @sensor_COLOR_SENSOR), do: {:ok, 28}
  def type(@command_PRESENTATION, @sensor_HVAC), do: {:ok, 29}
  def type(@command_PRESENTATION, @sensor_MULTIMETER), do: {:ok, 30}
  def type(@command_PRESENTATION, @sensor_SPRINKLER), do: {:ok, 31}
  def type(@command_PRESENTATION, @sensor_WATER_LEAK), do: {:ok, 32}
  def type(@command_PRESENTATION, @sensor_SOUND), do: {:ok, 33}
  def type(@command_PRESENTATION, @sensor_VIBRATION), do: {:ok, 34}
  def type(@command_PRESENTATION, @sensor_MOISTURE), do: {:ok, 35}
  def type(@command_PRESENTATION, @sensor_INFO), do: {:ok, 36}
  def type(@command_PRESENTATION, @sensor_GAS), do: {:ok, 37}
  def type(@command_PRESENTATION, @sensor_GPS), do: {:ok, 38}
  def type(@command_PRESENTATION, @sensor_WATER_QUALITY), do: {:ok, 39}
  def type(@command_PRESENTATION, _), do: {:error, @sensor_UNKNOWN}

  ## SET | REQ
  def type(t, 0) when t in [@command_SET, @command_REQ], do: {:ok, @value_TEMP}
  def type(t, 1) when t in [@command_SET, @command_REQ], do: {:ok, @value_HUM}
  def type(t, 2) when t in [@command_SET, @command_REQ], do: {:ok, @value_STATUS}
  def type(t, 3) when t in [@command_SET, @command_REQ], do: {:ok, @value_PERCENTAGE}
  def type(t, 4) when t in [@command_SET, @command_REQ], do: {:ok, @value_PRESSURE}
  def type(t, 5) when t in [@command_SET, @command_REQ], do: {:ok, @value_FORECAST}
  def type(t, 6) when t in [@command_SET, @command_REQ], do: {:ok, @value_RAIN}
  def type(t, 7) when t in [@command_SET, @command_REQ], do: {:ok, @value_RAINRATE}
  def type(t, 8) when t in [@command_SET, @command_REQ], do: {:ok, @value_WIND}
  def type(t, 9) when t in [@command_SET, @command_REQ], do: {:ok, @value_GUST}
  def type(t, 10) when t in [@command_SET, @command_REQ], do: {:ok, @value_DIRECTION}
  def type(t, 11) when t in [@command_SET, @command_REQ], do: {:ok, @value_UV}
  def type(t, 12) when t in [@command_SET, @command_REQ], do: {:ok, @value_WEIGHT}
  def type(t, 13) when t in [@command_SET, @command_REQ], do: {:ok, @value_DISTANCE}
  def type(t, 14) when t in [@command_SET, @command_REQ], do: {:ok, @value_IMPEDANCE}
  def type(t, 15) when t in [@command_SET, @command_REQ], do: {:ok, @value_ARMED}
  def type(t, 16) when t in [@command_SET, @command_REQ], do: {:ok, @value_TRIPPED}
  def type(t, 17) when t in [@command_SET, @command_REQ], do: {:ok, @value_WATT}
  def type(t, 18) when t in [@command_SET, @command_REQ], do: {:ok, @value_KWH}
  def type(t, 19) when t in [@command_SET, @command_REQ], do: {:ok, @value_SCENE_ON}
  def type(t, 20) when t in [@command_SET, @command_REQ], do: {:ok, @value_SCENE_OFF}
  def type(t, 21) when t in [@command_SET, @command_REQ], do: {:ok, @value_HVAC_FLOW_STATE}
  def type(t, 22) when t in [@command_SET, @command_REQ], do: {:ok, @value_HVAC_SPEED}
  def type(t, 23) when t in [@command_SET, @command_REQ], do: {:ok, @value_LIGHT_LEVEL}
  def type(t, 24) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR1}
  def type(t, 25) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR2}
  def type(t, 26) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR3}
  def type(t, 27) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR4}
  def type(t, 28) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR5}
  def type(t, 29) when t in [@command_SET, @command_REQ], do: {:ok, @value_UP}
  def type(t, 30) when t in [@command_SET, @command_REQ], do: {:ok, @value_DOWN}
  def type(t, 31) when t in [@command_SET, @command_REQ], do: {:ok, @value_STOP}
  def type(t, 32) when t in [@command_SET, @command_REQ], do: {:ok, @value_IR_SEND}
  def type(t, 33) when t in [@command_SET, @command_REQ], do: {:ok, @value_IR_RECEIVE}
  def type(t, 34) when t in [@command_SET, @command_REQ], do: {:ok, @value_FLOW}
  def type(t, 35) when t in [@command_SET, @command_REQ], do: {:ok, @value_VOLUME}
  def type(t, 36) when t in [@command_SET, @command_REQ], do: {:ok, @value_LOCK_STATUS}
  def type(t, 37) when t in [@command_SET, @command_REQ], do: {:ok, @value_LEVEL}
  def type(t, 38) when t in [@command_SET, @command_REQ], do: {:ok, @value_VOLTAGE}
  def type(t, 39) when t in [@command_SET, @command_REQ], do: {:ok, @value_CURRENT}
  def type(t, 40) when t in [@command_SET, @command_REQ], do: {:ok, @value_RGB}
  def type(t, 41) when t in [@command_SET, @command_REQ], do: {:ok, @value_RGBW}
  def type(t, 42) when t in [@command_SET, @command_REQ], do: {:ok, @value_ID}
  def type(t, 43) when t in [@command_SET, @command_REQ], do: {:ok, @value_UNIT_PREFIX}
  def type(t, 44) when t in [@command_SET, @command_REQ], do: {:ok, @value_HVAC_SETPOINT_COOL}
  def type(t, 45) when t in [@command_SET, @command_REQ], do: {:ok, @value_HVAC_SETPOINT_HEAT}
  def type(t, 46) when t in [@command_SET, @command_REQ], do: {:ok, @value_HVAC_FLOW_MODE}
  def type(t, 47) when t in [@command_SET, @command_REQ], do: {:ok, @value_TEXT}
  def type(t, 48) when t in [@command_SET, @command_REQ], do: {:ok, @value_CUSTOM}
  def type(t, 49) when t in [@command_SET, @command_REQ], do: {:ok, @value_POSITION}
  def type(t, 50) when t in [@command_SET, @command_REQ], do: {:ok, @value_IR_RECORD}
  def type(t, 51) when t in [@command_SET, @command_REQ], do: {:ok, @value_PH}
  def type(t, 52) when t in [@command_SET, @command_REQ], do: {:ok, @value_ORP}
  def type(t, 53) when t in [@command_SET, @command_REQ], do: {:ok, @value_EC}
  def type(t, 54) when t in [@command_SET, @command_REQ], do: {:ok, @value_VAR}
  def type(t, 55) when t in [@command_SET, @command_REQ], do: {:ok, @value_VA}
  def type(t, 56) when t in [@command_SET, @command_REQ], do: {:ok, @value_POWER_FACTOR}

  def type(t, @value_TEMP) when t in [@command_SET, @command_REQ], do: {:ok, 0}
  def type(t, @value_HUM) when t in [@command_SET, @command_REQ], do: {:ok, 1}
  def type(t, @value_STATUS) when t in [@command_SET, @command_REQ], do: {:ok, 2}
  def type(t, @value_PERCENTAGE) when t in [@command_SET, @command_REQ], do: {:ok, 3}
  def type(t, @value_PRESSURE) when t in [@command_SET, @command_REQ], do: {:ok, 4}
  def type(t, @value_FORECAST) when t in [@command_SET, @command_REQ], do: {:ok, 5}
  def type(t, @value_RAIN) when t in [@command_SET, @command_REQ], do: {:ok, 6}
  def type(t, @value_RAINRATE) when t in [@command_SET, @command_REQ], do: {:ok, 7}
  def type(t, @value_WIND) when t in [@command_SET, @command_REQ], do: {:ok, 8}
  def type(t, @value_GUST) when t in [@command_SET, @command_REQ], do: {:ok, 9}
  def type(t, @value_DIRECTION) when t in [@command_SET, @command_REQ], do: {:ok, 10}
  def type(t, @value_UV) when t in [@command_SET, @command_REQ], do: {:ok, 11}
  def type(t, @value_WEIGHT) when t in [@command_SET, @command_REQ], do: {:ok, 12}
  def type(t, @value_DISTANCE) when t in [@command_SET, @command_REQ], do: {:ok, 13}
  def type(t, @value_IMPEDANCE) when t in [@command_SET, @command_REQ], do: {:ok, 14}
  def type(t, @value_ARMED) when t in [@command_SET, @command_REQ], do: {:ok, 15}
  def type(t, @value_TRIPPED) when t in [@command_SET, @command_REQ], do: {:ok, 16}
  def type(t, @value_WATT) when t in [@command_SET, @command_REQ], do: {:ok, 17}
  def type(t, @value_KWH) when t in [@command_SET, @command_REQ], do: {:ok, 18}
  def type(t, @value_SCENE_ON) when t in [@command_SET, @command_REQ], do: {:ok, 19}
  def type(t, @value_SCENE_OFF) when t in [@command_SET, @command_REQ], do: {:ok, 20}
  def type(t, @value_HVAC_FLOW_STATE) when t in [@command_SET, @command_REQ], do: {:ok, 21}
  def type(t, @value_HVAC_SPEED) when t in [@command_SET, @command_REQ], do: {:ok, 22}
  def type(t, @value_LIGHT_LEVEL) when t in [@command_SET, @command_REQ], do: {:ok, 23}
  def type(t, @value_VAR1) when t in [@command_SET, @command_REQ], do: {:ok, 24}
  def type(t, @value_VAR2) when t in [@command_SET, @command_REQ], do: {:ok, 25}
  def type(t, @value_VAR3) when t in [@command_SET, @command_REQ], do: {:ok, 26}
  def type(t, @value_VAR4) when t in [@command_SET, @command_REQ], do: {:ok, 27}
  def type(t, @value_VAR5) when t in [@command_SET, @command_REQ], do: {:ok, 28}
  def type(t, @value_UP) when t in [@command_SET, @command_REQ], do: {:ok, 29}
  def type(t, @value_DOWN) when t in [@command_SET, @command_REQ], do: {:ok, 30}
  def type(t, @value_STOP) when t in [@command_SET, @command_REQ], do: {:ok, 31}
  def type(t, @value_IR_SEND) when t in [@command_SET, @command_REQ], do: {:ok, 32}
  def type(t, @value_IR_RECEIVE) when t in [@command_SET, @command_REQ], do: {:ok, 33}
  def type(t, @value_FLOW) when t in [@command_SET, @command_REQ], do: {:ok, 34}
  def type(t, @value_VOLUME) when t in [@command_SET, @command_REQ], do: {:ok, 35}
  def type(t, @value_LOCK_STATUS) when t in [@command_SET, @command_REQ], do: {:ok, 36}
  def type(t, @value_LEVEL) when t in [@command_SET, @command_REQ], do: {:ok, 37}
  def type(t, @value_VOLTAGE) when t in [@command_SET, @command_REQ], do: {:ok, 38}
  def type(t, @value_CURRENT) when t in [@command_SET, @command_REQ], do: {:ok, 39}
  def type(t, @value_RGB) when t in [@command_SET, @command_REQ], do: {:ok, 40}
  def type(t, @value_RGBW) when t in [@command_SET, @command_REQ], do: {:ok, 41}
  def type(t, @value_ID) when t in [@command_SET, @command_REQ], do: {:ok, 42}
  def type(t, @value_UNIT_PREFIX) when t in [@command_SET, @command_REQ], do: {:ok, 43}
  def type(t, @value_HVAC_SETPOINT_COOL) when t in [@command_SET, @command_REQ], do: {:ok, 44}
  def type(t, @value_HVAC_SETPOINT_HEAT) when t in [@command_SET, @command_REQ], do: {:ok, 45}
  def type(t, @value_HVAC_FLOW_MODE) when t in [@command_SET, @command_REQ], do: {:ok, 46}
  def type(t, @value_TEXT) when t in [@command_SET, @command_REQ], do: {:ok, 47}
  def type(t, @value_CUSTOM) when t in [@command_SET, @command_REQ], do: {:ok, 48}
  def type(t, @value_POSITION) when t in [@command_SET, @command_REQ], do: {:ok, 49}
  def type(t, @value_IR_RECORD) when t in [@command_SET, @command_REQ], do: {:ok, 50}
  def type(t, @value_PH) when t in [@command_SET, @command_REQ], do: {:ok, 51}
  def type(t, @value_ORP) when t in [@command_SET, @command_REQ], do: {:ok, 52}
  def type(t, @value_EC) when t in [@command_SET, @command_REQ], do: {:ok, 53}
  def type(t, @value_VAR) when t in [@command_SET, @command_REQ], do: {:ok, 54}
  def type(t, @value_VA) when t in [@command_SET, @command_REQ], do: {:ok, 55}
  def type(t, @value_POWER_FACTOR) when t in [@command_SET, @command_REQ], do: {:ok, 56}
  def type(t, _) when t in [@command_SET, @command_REQ], do: {:error, @value_UNKNOWN}

  ## INTERNAL
  def type(@command_INTERNAL, 0), do: {:ok, @internal_BATTERY_LEVEL}
  def type(@command_INTERNAL, 1), do: {:ok, @internal_TIME}
  def type(@command_INTERNAL, 2), do: {:ok, @internal_VERSION}
  def type(@command_INTERNAL, 3), do: {:ok, @internal_ID_REQUEST}
  def type(@command_INTERNAL, 4), do: {:ok, @internal_ID_RESPONSE}
  def type(@command_INTERNAL, 5), do: {:ok, @internal_INCLUSION_MODE}
  def type(@command_INTERNAL, 6), do: {:ok, @internal_CONFIG}
  def type(@command_INTERNAL, 7), do: {:ok, @internal_FIND_PARENT}
  def type(@command_INTERNAL, 8), do: {:ok, @internal_FIND_PARENT_RESPONSE}
  def type(@command_INTERNAL, 9), do: {:ok, @internal_LOG_MESSAGE}
  def type(@command_INTERNAL, 10), do: {:ok, @internal_CHILDREN}
  def type(@command_INTERNAL, 11), do: {:ok, @internal_SKETCH_NAME}
  def type(@command_INTERNAL, 12), do: {:ok, @internal_SKETCH_VERSION}
  def type(@command_INTERNAL, 13), do: {:ok, @internal_REBOOT}
  def type(@command_INTERNAL, 14), do: {:ok, @internal_GATEWAY_READY}
  def type(@command_INTERNAL, 15), do: {:ok, @internal_SIGNING_PRESENTATION}
  def type(@command_INTERNAL, 16), do: {:ok, @internal_NONCE_REQUEST}
  def type(@command_INTERNAL, 17), do: {:ok, @internal_NONCE_RESPONSE}
  def type(@command_INTERNAL, 18), do: {:ok, @internal_HEARTBEAT_REQUEST}
  def type(@command_INTERNAL, 19), do: {:ok, @internal_PRESENTATION}
  def type(@command_INTERNAL, 20), do: {:ok, @internal_DISCOVER_REQUEST}
  def type(@command_INTERNAL, 21), do: {:ok, @internal_DISCOVER_RESPONSE}
  def type(@command_INTERNAL, 22), do: {:ok, @internal_HEARTBEAT_RESPONSE}
  def type(@command_INTERNAL, 23), do: {:ok, @internal_LOCKED}
  def type(@command_INTERNAL, 24), do: {:ok, @internal_PING}
  def type(@command_INTERNAL, 25), do: {:ok, @internal_PONG}
  def type(@command_INTERNAL, 26), do: {:ok, @internal_REGISTRATION_REQUEST}
  def type(@command_INTERNAL, 27), do: {:ok, @internal_REGISTRATION_RESPONSE}
  def type(@command_INTERNAL, 28), do: {:ok, @internal_DEBUG}

  def type(@command_INTERNAL, @internal_BATTERY_LEVEL), do: {:ok, 0}
  def type(@command_INTERNAL, @internal_TIME), do: {:ok, 1}
  def type(@command_INTERNAL, @internal_VERSION), do: {:ok, 2}
  def type(@command_INTERNAL, @internal_ID_REQUEST), do: {:ok, 3}
  def type(@command_INTERNAL, @internal_ID_RESPONSE), do: {:ok, 4}
  def type(@command_INTERNAL, @internal_INCLUSION_MODE), do: {:ok, 5}
  def type(@command_INTERNAL, @internal_CONFIG), do: {:ok, 6}
  def type(@command_INTERNAL, @internal_FIND_PARENT), do: {:ok, 7}
  def type(@command_INTERNAL, @internal_FIND_PARENT_RESPONSE), do: {:ok, 8}
  def type(@command_INTERNAL, @internal_LOG_MESSAGE), do: {:ok, 9}
  def type(@command_INTERNAL, @internal_CHILDREN), do: {:ok, 10}
  def type(@command_INTERNAL, @internal_SKETCH_NAME), do: {:ok, 11}
  def type(@command_INTERNAL, @internal_SKETCH_VERSION), do: {:ok, 12}
  def type(@command_INTERNAL, @internal_REBOOT), do: {:ok, 13}
  def type(@command_INTERNAL, @internal_GATEWAY_READY), do: {:ok, 14}
  def type(@command_INTERNAL, @internal_SIGNING_PRESENTATION), do: {:ok, 15}
  def type(@command_INTERNAL, @internal_NONCE_REQUEST), do: {:ok, 16}
  def type(@command_INTERNAL, @internal_NONCE_RESPONSE), do: {:ok, 17}
  def type(@command_INTERNAL, @internal_HEARTBEAT_REQUEST), do: {:ok, 18}
  def type(@command_INTERNAL, @internal_PRESENTATION), do: {:ok, 19}
  def type(@command_INTERNAL, @internal_DISCOVER_REQUEST), do: {:ok, 20}
  def type(@command_INTERNAL, @internal_DISCOVER_RESPONSE), do: {:ok, 21}
  def type(@command_INTERNAL, @internal_HEARTBEAT_RESPONSE), do: {:ok, 22}
  def type(@command_INTERNAL, @internal_LOCKED), do: {:ok, 23}
  def type(@command_INTERNAL, @internal_PING), do: {:ok, 24}
  def type(@command_INTERNAL, @internal_PONG), do: {:ok, 25}
  def type(@command_INTERNAL, @internal_REGISTRATION_REQUEST), do: {:ok, 26}
  def type(@command_INTERNAL, @internal_REGISTRATION_RESPONSE), do: {:ok, 27}
  def type(@command_INTERNAL, @internal_DEBUG), do: {:ok, 28}

  def type(@command_INTERNAL, _), do: {:error, @internal_UNKNOWN}
  
  def type(@command_STREAM, _), do: {:error, @stream_UNKNOWN}

  @compile {:inline, ack: 1}
  def ack(1), do: {:ok, @ack_TRUE}
  def ack(0), do: {:ok, @ack_FALSE}
  def ack(@ack_TRUE), do: {:ok, 1}
  def ack(@ack_FALSE), do: {:ok, 0}
  def ack(_), do: {:error, @ack_UNKNOWN}

  @type type :: String.t
  @type command :: String.t
  @type ack :: String.t
  @type payload :: binary
  @type node_id :: integer
  @type child_sensor_id :: integer

  @typedoc "MySensors packet"
  @type t :: %__MODULE__{
          node_id: node_id,
          child_sensor_id: child_sensor_id,
          command: command,
          type: type,
          ack: ack,
          payload: payload
        }

  @compile {:inline, decode: 1}
  def decode(binary) when is_binary(binary) do
    binary
    |> String.trim()
    |> String.split(";")
    |> decode()
  end

  def decode([node_id_str, child_sensor_id_str, command_str, ack_str, type_str, payload_str]) do
    with {:ok, ack} <- ack_str |> String.to_integer() |> ack(),
         {:ok, command} <- command_str |> String.to_integer() |> command(),
         {:ok, type} <- type(command, String.to_integer(type_str)),
         {node_id, _} <- Integer.parse(node_id_str),
         {child_sensor_id, _} <- Integer.parse(child_sensor_id_str) do
      opts = [
        node_id: node_id,
        child_sensor_id: child_sensor_id,
        command: command,
        type: type,
        ack: ack,
        payload: payload_str
      ]

      {:ok, struct(__MODULE__, opts)}
    else
      :error -> {:error, :id_not_integer}
      {:error, _} = err -> err
    end
  end

  def decode(list) when is_list(list) do
    {:error, :bad_packet}
  end

  def encode(%__MODULE__{} = packet) do
    with {:ok, command_id} <- command(packet.command),
         {:ok, type_id} <- type(packet.command, packet.type),
         {:ok, ack} <- ack(packet.ack) do
      packet_list = [
        packet.node_id,
        packet.child_sensor_id,
        command_id,
        ack,
        type_id,
        packet.payload
      ]

      packet_string = Enum.join(packet_list, ";")
      {:ok, packet_string}
    else
      {:error, _} = err -> err
    end
  end
end
