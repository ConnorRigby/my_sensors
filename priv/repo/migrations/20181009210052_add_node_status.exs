defmodule MySensors.Repo.Migrations.AddNodeStatus do
  use Ecto.Migration

  def change do
    alter table("nodes") do
      add :status, :string
    end
  end
end
