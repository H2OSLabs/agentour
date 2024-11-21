defmodule Agentour.Agents do
  import Ecto.Query, warn: false
  alias Agentour.Repo
  alias Agentour.Agents.Agent
  alias Agentour.Accounts.User

  def list_user_agents(user) do
    from(a in Agent,
      where: a.user_id == ^user.id,
      order_by: [desc: a.inserted_at]
    )
    |> Repo.all()
  end

  def list_agents_by_user(%User{} = user) do
    Agent
    |> where([a], a.user_id == ^user.id)
    |> Repo.all()
  end

  def get_agent!(id), do: Repo.get!(Agent, id)

  def create_agent(attrs \\ %{}) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Repo.insert()
  end

  def update_agent(%Agent{} = agent, attrs) do
    agent
    |> Agent.changeset(attrs)
    |> Repo.update()
  end

  def delete_agent(%Agent{} = agent) do
    Repo.delete(agent)
  end

  def change_agent(%Agent{} = agent, attrs \\ %{}) do
    Agent.changeset(agent, attrs)
  end
end
