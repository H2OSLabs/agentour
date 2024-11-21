defmodule Agentour.Agents.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agents" do
    field :name, :string
    field :type, :string
    field :capabilities, {:array, :string}
    field :metadata, :map

    belongs_to :user, Agentour.Accounts.User
    many_to_many :sessions, Agentour.Sessions.Session, join_through: "agents_sessions"

    timestamps()
  end

  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :type, :capabilities, :metadata, :user_id])
    |> validate_required([:name, :type, :user_id])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_inclusion(:type, ["assistant", "user", "system", "tool"])
    |> foreign_key_constraint(:user_id)
  end
end
