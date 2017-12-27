defmodule MySensors.SensorValue do
  @moduledoc "SensorValue Object"

  use Ecto.Schema
  import Ecto.Changeset
  alias MySensors.{Sensor, SensorValue}

  @typedoc @moduledoc
  @type t :: %__MODULE__{}

  @optional_params []
  @required_params [:sensor_id, :type, :value]

  @json_handler Application.get_env(:my_sensors, :json_handler)
  @derive {Module.concat(@json_handler, "Encoder"), except: [:__meta__, :__struct, :sensor]}

  schema "sensor_values" do
    belongs_to :sensor, Sensor
    field :type, :string
    field :value, :float
    timestamps()
  end

  def changeset(%SensorValue{} = sensor_value, params \\ %{}) do
    sensor_value
    |> cast(params, @optional_params ++ @required_params)
    |> validate_required(@required_params)
  end
end
