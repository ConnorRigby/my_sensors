defmodule MySensors.Node do
  @moduledoc "Node Object"

  use Ecto.Schema
  import Ecto.Changeset
  alias MySensors.{Node, Sensor}

  @typedoc @moduledoc
  @type t :: %__MODULE__{}

  @optional_params [:battery_level, :protocol, :sketch_name, :sketch_version, :config]
  @required_params []

  @json_handler Application.get_env(:my_sensors, :json_handler)
  @json_handler || Mix.raise("No JSON handler configured!")
  @derive {Module.concat(@json_handler, "Encoder"), except: [:__meta__, :__struct__, :sensors]}

  schema "nodes" do
    has_many :sensors, Sensor, on_delete: :delete_all
    field :battery_level, :integer
    field :protocol, :string
    field :sketch_name, :string
    field :sketch_version, :string
    field :config, :string
    timestamps()
  end

  def changeset(%Node{} = node, params \\ %{}) do
    node
      |> cast(params, @optional_params ++ @required_params)
      |> validate_required(@required_params)
  end
end
