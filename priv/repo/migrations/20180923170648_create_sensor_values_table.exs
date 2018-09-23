defmodule MySensors.Repo.Migrations.CreateSensorValuesTable do
  use Ecto.Migration

  def change do
    create table("sensor_values") do
      add :type, :string
      add :value, :float
      add :sensor_id, references("sensors", on_delete: :delete_all)
      timestamps()
    end
  end
end
