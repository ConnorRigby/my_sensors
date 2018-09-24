defmodule MySensors.SensorValue do
  @moduledoc "SensorValue Object"

  use Ecto.Schema
  import Ecto.Changeset

  schema "sensor_values" do
    field(:type, :string)
    field(:value, :float)
    belongs_to(:sensor, MySensors.Sensor)
    timestamps()
  end

  @optional [:type, :value]

  def changeset(sensor_value, params \\ %{}) do
    sensor_value
    |> cast(params, @optional)
    |> validate_required([])
  end

  @type t :: %__MODULE__{
          type: String.t(),
          value: float
        }
end
