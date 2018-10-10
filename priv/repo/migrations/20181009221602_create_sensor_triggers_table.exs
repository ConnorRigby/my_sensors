defmodule MySensors.Repo.Migrations.CreateSensorTriggersTable do
  use Ecto.Migration

  def change do
    create table("sensor_triggers") do
      add :name, :string
      add :valid_from_datetime, :utc_datetime
      add :valid_to_datetime, :utc_datetime
      add :valid_from_time, :time
      add :valid_to_time, :time
      add :value_type, :string
      add :value_condition, :string
      add :value_comparison, :float
      add :payload, :float
      add :executor_sensor_id, references("sensors", on_delete: :delete_all)
      add :executee_sensor_id, references("sensors", on_delete: :delete_all)
      timestamps()
    end

    create unique_index("sensor_triggers", [:name])
  end
end
