defmodule MySensors.Sensor do
  @moduledoc "Sensor Object"

  use Ecto.Schema
  import Ecto.Changeset
  alias MySensors.{Node, Sensor, SensorValue}

  @typedoc @moduledoc
  @type t :: %__MODULE__{}

  @optional_params []
  @required_params [:node_id, :child_sensor_id, :type]

  @derive {Poison.Encoder, except: [:__meta__, :__struct, :node]}

  schema "sensors" do
    belongs_to :node, Node
    has_many :sensor_values, SensorValue, on_delete: :delete_all
    field :child_sensor_id, :integer
    field :type, :string
    timestamps()
  end

  def changeset(%Sensor{} = sensor, params \\ %{}) do
    sensor
    |> cast(params, @optional_params ++ @required_params)
    |> validate_required(@required_params)
  end
end
