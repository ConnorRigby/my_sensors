defmodule MySensors.Repo.Migrations.AddSensorsTable do
  use Ecto.Migration

  def change do
    create table("sensors") do
      add :node_id, references("nodes", on_delete: :delete_all)
      add :child_sensor_id, :integer
      add :type, :string
      timestamps()
    end
  end
end
