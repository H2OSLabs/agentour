defmodule Agentour.Repo.Migrations.AddMetadataToAgents do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :metadata, :map, default: %{}
    end
  end
end
