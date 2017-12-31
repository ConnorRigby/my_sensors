defmodule MySensors.Node do
  @moduledoc "Node Object"

  alias MySensors.Sensor
  import Record

  @keys [
    :id,
    :battery_level,
    :protocol,
    :sketch_name,
    :sketch_version,
    :config,
    :sensors
  ]

  defrecord __MODULE__, @keys
  defstruct @keys

  def keys, do: @keys

  def to_struct({__MODULE__,
    id, battery_level, protocol, sketch_name, sketch_version, config, sensors
  }) do
    struct(__MODULE__, [
      id: id,
      battery_level: battery_level,
      protocol: protocol,
      sketch_name: sketch_name,
      sketch_version: sketch_version,
      config: config,
      sensors: Enum.map(sensors || [], &Sensor.to_struct(&1))
    ])
  end

  def from_struct(%__MODULE__{ id: id, battery_level: battery_level, protocol: protocol,
    sketch_name: sketch_name, sketch_version: sketch_version, config: config, sensors: sensors
  }) do
    {__MODULE__,
      id, battery_level, protocol, sketch_name, sketch_version, config, Enum.map(sensors || [], &Sensor.from_struct(&1))
    }
  end

  @typedoc false
  @type t :: %__MODULE__{
    id: integer,
    battery_level: number | nil,
    protocol: String.t | nil,
    sketch_name: String.t | nil,
    sketch_version: String.t | nil,
    config: String.t | nil,
    sensors: [Sensor.t]
  }
end
