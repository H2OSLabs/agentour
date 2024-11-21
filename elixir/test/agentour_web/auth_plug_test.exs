defmodule AgentourWeb.AuthPlugTest do
  use AgentourWeb.ConnCase
  alias Agentour.Accounts
  alias AgentourWeb.AuthPlug

  @valid_attrs %{
    email: "test@example.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    name: "Test User"
  }

  setup %{conn: conn} do
    {:ok, user} = Accounts.register_user(@valid_attrs)
    conn = 
      conn
      |> init_test_session(%{})
      |> fetch_flash()
    %{conn: conn, user: user}
  end

  describe "fetch_current_user" do
    test "assigns nil when no session exists", %{conn: conn} do
      conn = AuthPlug.call(conn, :fetch_current_user)
      assert is_nil(conn.assigns.current_user)
    end

    test "assigns user when valid session exists", %{conn: conn, user: user} do
      conn =
        conn
        |> put_session("current_user_id", user.id)
        |> AuthPlug.call(:fetch_current_user)

      assert conn.assigns.current_user.id == user.id
    end

    test "clears session and assigns nil when user_id is invalid", %{conn: conn} do
      conn =
        conn
        |> put_session("current_user_id", -1)
        |> AuthPlug.call(:fetch_current_user)

      assert is_nil(conn.assigns.current_user)
      assert is_nil(get_session(conn, "current_user_id"))
    end

    test "handles non-integer user_id gracefully", %{conn: conn} do
      conn =
        conn
        |> put_session("current_user_id", "invalid")
        |> AuthPlug.call(:fetch_current_user)

      assert is_nil(conn.assigns.current_user)
      assert is_nil(get_session(conn, "current_user_id"))
    end

    test "preserves session key name", %{conn: conn, user: user} do
      conn =
        conn
        |> put_session("current_user_id", user.id)
        |> AuthPlug.call(:fetch_current_user)

      assert get_session(conn, "current_user_id") == user.id
    end
  end

  describe "ensure_authenticated" do
    test "allows access when user is authenticated", %{conn: conn, user: user} do
      conn =
        conn
        |> assign(:current_user, user)
        |> AuthPlug.call(:ensure_authenticated)

      refute conn.halted
    end

    test "redirects to login when no user is assigned", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, nil)
        |> AuthPlug.call(:ensure_authenticated)

      assert conn.halted
      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "redirects to login when user is not assigned", %{conn: conn} do
      conn = AuthPlug.call(conn, :ensure_authenticated)

      assert conn.halted
      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) == "You must log in to access this page."
    end
  end
end
