defmodule MySensors.Node do
  @moduledoc "Node Object"
  alias MySensors.Sensor
  
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :battery_level, :float
    field :protocol, :string
    field :sketch_name, :string
    field :sketch_version, :string
    field :config, :string
    has_many(:sensors, MySensors.Sensor)
    timestamps()
  end

  @optional [:battery_level, :protocol, :sketch_name, :sketch_version, :config]

  def changeset(node, params \\ %{}) do
    node
    |> cast(params, @optional)
    |> validate_required([])
  end

  @type t :: %__MODULE__{
    battery_level: number | nil,
    protocol: String.t() | nil,
    sketch_name: String.t() | nil,
    sketch_version: String.t() | nil,
    config: String.t() | nil,
    sensors: [Sensor.t()] | nil
  }
end
