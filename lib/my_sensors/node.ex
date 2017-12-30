defmodule MySensors.Node do
  @moduledoc "Node Object"

  alias MySensors.{Node, Sensor}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    battery_level: number | nil,
    protocol: String.t | nil,
    sketch_name: String.t | nil,
    sketch_version: String.t | nil,
    config: String.t | nil
  }

  defstruct [:battery_level, :protocol, :sketch_name, :sketch_version, :config, :id]

  @json_handler Application.get_env(:my_sensors, :json_handler)
  @json_handler || Mix.raise("No JSON handler configured!")
  @derive {Module.concat(@json_handler, "Encoder"), except: [:__meta__, :__struct__, :sensors]}
end
