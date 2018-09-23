defmodule MySensors.Repo.Migrations.CreateSensorsTable do
  use Ecto.Migration

  def change do
    create table("sensors") do
      add :type, :string
      add :child_sensor_id, :integer
      add :node_id, references("nodes", on_delete: :delete_all)
      timestamps()
    end
    create unique_index("sensors", [:child_sensor_id, :node_id])
  end
end
