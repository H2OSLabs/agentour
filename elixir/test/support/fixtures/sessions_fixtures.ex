defmodule Agentour.SessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agentour.Sessions` context.
  """

  def session_fixture(attrs \\ %{}) do
    owner = attrs[:owner] || Agentour.AccountsFixtures.user_fixture()

    {:ok, session} =
      attrs
      |> Enum.into(%{
        name: "Test Session",
        description: "Test Description",
        owner_id: owner.id,
        status: "active"
      })
      |> Agentour.Sessions.create_session()

    session
  end
end
