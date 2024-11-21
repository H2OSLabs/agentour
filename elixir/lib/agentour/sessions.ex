defmodule Agentour.Sessions do
  import Ecto.Query
  alias Agentour.Repo
  alias Agentour.Sessions.Session
  alias Agentour.Agents.Agent

  def list_user_sessions(user) do
    from(s in Session,
      where: s.owner_id == ^user.id,
      order_by: [desc: s.inserted_at]
    )
    |> Repo.all()
    |> Repo.preload([:agents])
  end

  def get_session!(id), do: Repo.get!(Session, id) |> Repo.preload([:agents])

  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  def add_agent_to_session(%Session{} = session, %Agent{} = agent) do
    session
    |> Repo.preload(:agents)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:agents, [agent | session.agents])
    |> Repo.update()
  end

  def remove_agent_from_session(%Session{} = session, %Agent{} = agent) do
    session
    |> Repo.preload(:agents)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:agents, Enum.reject(session.agents, &(&1.id == agent.id)))
    |> Repo.update()
  end
end
