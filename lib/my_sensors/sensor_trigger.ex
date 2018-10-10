defmodule MySensors.SensorTrigger do
  use Ecto.Schema
  import Ecto.Changeset
  alias MySensors.Sensor
  {:ok, default_valid_from_time} = Time.new(0, 0, 0)
  {:ok, default_valid_to_time} = Time.new(23, 59, 59)
  @default_valid_from_time default_valid_from_time
  @default_valid_to_time default_valid_to_time

  schema "sensor_triggers" do
    field(:name, :string)
    field(:valid_from_datetime, :utc_datetime)
    field(:valid_to_datetime, :utc_datetime)
    field(:valid_from_time, :time, default: @default_valid_from_time, null: false)
    field(:valid_to_time, :time, default: @default_valid_to_time)
    field(:value_condition, :string)
    field(:value_comparison, :float)
    field(:value_type, :string)
    field(:payload, :float)
    belongs_to(:executor_sensor, Sensor)
    belongs_to(:executee_sensor, Sensor)
    timestamps()
  end

  @optional [
    :name,
    :valid_to_datetime,
    :valid_from_datetime,
    :valid_from_time,
    :valid_to_time
  ]

  @required [
    :name,
    :valid_from_datetime,
    :valid_to_datetime,
    :value_condition,
    :value_comparison,
    :value_type,
    :payload
  ]

  def changeset(sensor_trigger, params \\ %{}) do
    sensor_trigger
    |> cast(params, @optional ++ @required)
    |> validate_required(@required)
    |> validate_inclusion(:value_condition, [">", ">=", "<", "<=", "==", "!="])

    # |> unique_constraint([:name])
  end

  @type t :: %__MODULE__{}
end
