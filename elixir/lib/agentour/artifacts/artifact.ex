defmodule Agentour.Artifacts.Artifact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artifacts" do
    field :name, :string
    field :type, :string  # file, text, code, etc.
    field :content, :string
    field :metadata, :map
    
    belongs_to :session, Agentour.Sessions.Session
    belongs_to :creator, Agentour.Agents.Agent
    
    timestamps()
  end

  def changeset(artifact, attrs) do
    artifact
    |> cast(attrs, [:name, :type, :content, :metadata, :session_id, :creator_id])
    |> validate_required([:name, :type, :session_id, :creator_id])
    |> foreign_key_constraint(:session_id)
    |> foreign_key_constraint(:creator_id)
  end
end
