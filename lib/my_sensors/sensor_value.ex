defmodule MySensors.SensorValue do
  @moduledoc "SensorValue Object"

  import Record

  @keys [
    :sensor_id,
    :type,
    :value
  ]

  defstruct @keys
  defrecord __MODULE__, @keys

  @typedoc false
  @type t :: %__MODULE__{
          sensor_id: integer,
          type: String.t(),
          value: any
        }

  def to_struct({__MODULE__, sensor_id, type, value}) do
    struct(__MODULE__, sensor_id: sensor_id, type: type, value: value)
  end

  def from_struct(%__MODULE__{sensor_id: sensor_id, type: type, value: value}) do
    {__MODULE__, sensor_id, type, value}
  end

  def keys, do: @keys
end
