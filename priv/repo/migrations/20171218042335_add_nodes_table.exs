defmodule MySensors.Repo.Migrations.AddNodesTable do
  use Ecto.Migration

  def change do
    create table("nodes") do
      add :battery_level, :integer
      add :protocol, :string
      add :sketch_name, :string
      add :sketch_version, :string
      add :config, :string
      timestamps()
    end
  end
end
