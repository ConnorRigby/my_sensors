defmodule MySensors.Repo.Migrations.AddSensorValuesTable do
  use Ecto.Migration

  def change do
    create table("sensor_values") do
      add :sensor_id, references("sensors", on_delete: :delete_all)
      add :value, :float
      add :type, :string
      timestamps()
    end
  end
end
