defmodule Agentour.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :name, :string
    field :status, :string, default: "active"  # active, archived
    field :description, :string
    
    belongs_to :owner, Agentour.Accounts.User
    many_to_many :agents, Agentour.Agents.Agent, join_through: "agents_sessions"
    has_many :artifacts, Agentour.Artifacts.Artifact
    
    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:name, :status, :description, :owner_id])
    |> validate_required([:name, :owner_id])
    |> validate_inclusion(:status, ["active", "archived"])
    |> foreign_key_constraint(:owner_id)
  end
end
