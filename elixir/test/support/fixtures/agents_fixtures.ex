defmodule Agentour.AgentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agentour.Agents` context.
  """

  import Agentour.AccountsFixtures

  def valid_agent_attributes(attrs \\ %{}) do
    user = attrs[:user] || user_fixture()
    
    base_attrs = %{
      name: "test agent #{System.unique_integer()}",
      description: "some description",
      type: "assistant",
      model: "gpt-4",
      temperature: 0.7,
      max_tokens: 1000,
      user_id: user.id
    }

    attrs = Map.drop(attrs, [:user])
    Enum.into(attrs, base_attrs)
  end

  def agent_fixture(attrs \\ %{}) do
    {:ok, agent} =
      attrs
      |> valid_agent_attributes()
      |> Agentour.Agents.create_agent()

    agent
  end
end
