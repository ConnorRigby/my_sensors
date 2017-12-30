defmodule MySensors.Sensor do
  @moduledoc "Sensor Object"

  alias MySensors.{Node, Sensor, SensorValue}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    node_id: number,
    child_sensor_id: number,
    type: String.t
  }

  defstruct [:node_id, :child_sensor_id, :type, :id]

  @json_handler Application.get_env(:my_sensors, :json_handler)
  @derive {Module.concat(@json_handler, "Encoder"), except: [:__meta__, :__struct, :node]}
end
