defmodule MySensors.Sensor do
  @moduledoc "Sensor Object"

  alias MySensors.SensorValue
  import Record

  @keys [
    :child_sensor_id,
    :node_id,
    :type,
    :sensor_values
  ]

  @typedoc false
  @type t :: %__MODULE__{
          child_sensor_id: integer,
          node_id: integer,
          type: String.t(),
          sensor_values: [SensorValue.t()]
        }

  defstruct @keys
  defrecord __MODULE__, @keys

  def to_struct({__MODULE__, child_sensor_id, node_id, type, sensor_values}) do
    struct(__MODULE__,
      child_sensor_id: child_sensor_id,
      node_id: node_id,
      type: type,
      sensor_values: Enum.map(sensor_values, &SensorValue.to_struct(&1))
    )
  end

  def from_struct(%__MODULE__{
        child_sensor_id: child_sensor_id,
        node_id: node_id,
        type: type,
        sensor_values: sensor_values
      }) do
    {__MODULE__, child_sensor_id, node_id, type,
     Enum.map(sensor_values, &SensorValue.from_struct(&1))}
  end

  def keys, do: @keys
end
