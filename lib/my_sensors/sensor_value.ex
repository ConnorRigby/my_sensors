defmodule MySensors.SensorValue do
  @moduledoc "SensorValue Object"

  alias MySensors.{Sensor, SensorValue}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    sensor_id: number,
    type: String.t,
    value: Float.t
  }

  defstruct [:sensor_id, :type, :value, :id]

  @json_handler Application.get_env(:my_sensors, :json_handler)
  @derive {Module.concat(@json_handler, "Encoder"), except: [:__meta__, :__struct, :sensor]}
end
