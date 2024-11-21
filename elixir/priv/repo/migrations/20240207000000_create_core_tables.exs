defmodule Agentour.Repo.Migrations.CreateCoreTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:agents) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :capabilities, {:array, :string}
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:agents, [:user_id])

    create table(:sessions) do
      add :name, :string, null: false
      add :status, :string, default: "active"
      add :description, :text
      add :owner_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:sessions, [:owner_id])

    create table(:agents_sessions) do
      add :agent_id, references(:agents, on_delete: :delete_all), null: false
      add :session_id, references(:sessions, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:agents_sessions, [:agent_id, :session_id])

    create table(:artifacts) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :content, :text
      add :metadata, :map
      add :session_id, references(:sessions, on_delete: :delete_all), null: false
      add :creator_id, references(:agents, on_delete: :nilify_all)

      timestamps()
    end

    create index(:artifacts, [:session_id])
    create index(:artifacts, [:creator_id])
  end
end
