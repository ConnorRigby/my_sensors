defmodule MySensors.Repo.Migrations.CreateNodesTable do
  use Ecto.Migration

  def change do
    create table("nodes") do
      add :battery_level, :float
      add :protocol, :string
      add :sketch_name, :string
      add :sketch_version, :string
      add :config, :string
      timestamps()
    end
  end
end
