defmodule MySensors.Node do
  @moduledoc "Node Object"
  alias MySensors.Sensor

  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field(:name, :string)
    field(:battery_level, :float)
    field(:protocol, :string)
    field(:sketch_name, :string)
    field(:sketch_version, :string)
    field(:config, :string)
    has_many(:sensors, MySensors.Sensor, on_delete: :delete_all)
    timestamps()
  end

  @optional [:id, :name, :battery_level, :protocol, :sketch_name, :sketch_version, :config]

  def changeset(node, params \\ %{}) do
    node
    |> cast(params, @optional)
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
