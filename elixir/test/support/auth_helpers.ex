defmodule AgentourWeb.AuthHelpers do
  @moduledoc """
  Helper functions for authentication in tests.
  """

  import Agentour.AccountsFixtures
  import Phoenix.ConnTest
  import Plug.Conn

  def register_and_log_in_user(context) when is_map(context) do
    conn = Map.get(context, :conn) || build_conn()
    user = user_fixture()
    conn = log_in_user(conn, user)
    %{conn: conn, user: user}
  end

  def register_and_log_in_user({:ok, context}) when is_list(context) do
    conn = Keyword.get(context, :conn) || build_conn()
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, %{conn: conn, user: user}}
  end

  def log_in_user(conn, user) do
    token = Agentour.Accounts.generate_user_session_token(user)

    conn
    |> init_test_session(%{})
    |> put_session(:user_token, token)
    |> put_session(:current_user_id, user.id)
  end
end
