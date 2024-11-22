defmodule Agentour.ArtifactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agentour.Artifacts` context.
  """

  import Agentour.AccountsFixtures
  import Agentour.SessionsFixtures
  import Agentour.AgentsFixtures

  def unique_artifact_name, do: "test artifact #{System.unique_integer()}"

  def valid_artifact_attrs(attrs \\ %{}) do
    owner = attrs[:user] || user_fixture()
    session = session_fixture(%{owner: owner})
    agent = agent_fixture(%{user: owner})

    Enum.into(attrs, %{
      name: unique_artifact_name(),
      type: "text",
      metadata: %{"key" => "value"},
      session_id: session.id,
      content: "test content",
      creator_id: agent.id
    })
  end

  def artifact_fixture(attrs \\ %{}) do
    {:ok, artifact} =
      attrs
      |> valid_artifact_attrs()
      |> Agentour.Artifacts.create_artifact()

    artifact
  end
end
