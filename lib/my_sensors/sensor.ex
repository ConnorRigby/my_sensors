defmodule MySensors.Sensor do
  @moduledoc "Sensor Object"

  use Ecto.Schema
  import Ecto.Changeset
  alias MySensors.{Node, SensorValue}

  schema "sensors" do
    field :type, :string
    field :child_sensor_id, :integer
    belongs_to(:node, Node, on_replace: :delete)
    has_many(:sensor_values, SensorValue, on_delete: :delete_all)
    timestamps()
  end

  @optional [:type, :child_sensor_id]

  def changeset(sensor, params \\ %{}) do
    sensor
    |> cast(params, @optional)
    |> validate_required([])
    |> unique_constraint(:child_sensor_id, name: :sensors_child_sensor_id_node_id_index)
  end

  @type t :: %__MODULE__{
    child_sensor_id: integer,
    type: String.t(),
    sensor_values: [SensorValue.t()]
  }
end
