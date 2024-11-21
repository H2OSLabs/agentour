defmodule AgentourWeb.SessionLive.IndexTest do
  use AgentourWeb.ConnCase
  import Phoenix.LiveViewTest
  import AgentourWeb.AuthHelpers
  import Agentour.SessionsFixtures
  import Agentour.AccountsFixtures

  describe "unauthenticated access" do
    test "redirects to login page when accessing index page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/sessions")
    end

    test "redirects to login page when accessing new session page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/sessions/new")
    end

    test "redirects to login page when accessing edit session page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/sessions/1/edit")
    end
  end

  describe "authenticated access" do
    setup %{conn: conn} do
      {:ok, conn: conn} |> register_and_log_in_user()
    end

    test "renders index page successfully", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/sessions")
      assert html =~ "Your Sessions"
    end

    test "current_user is properly assigned", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/sessions")
      assert view.assigns.current_user.id == user.id
    end

    test "lists user's sessions", %{conn: conn, user: user} do
      session = session_fixture(%{owner: user})
      {:ok, view, _html} = live(conn, ~p"/sessions")
      assert has_element?(view, "#sessions-#{session.id}")
    end

    test "can access new session page", %{conn: conn} do
      {:ok, _view, _html} = live(conn, ~p"/sessions")
      {:ok, _view, html} = live(conn, ~p"/sessions/new")
      assert html =~ "New Session"
    end

    test "can access edit session page", %{conn: conn, user: user} do
      session = session_fixture(%{owner: user})
      {:ok, _view, _html} = live(conn, ~p"/sessions")
      {:ok, _view, html} = live(conn, ~p"/sessions/#{session.id}/edit")
      assert html =~ "Edit Session"
    end
  end

  describe "session persistence" do
    setup %{conn: conn} do
      {:ok, conn: conn} |> register_and_log_in_user()
    end

    test "maintains user session after navigation", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/sessions")
      assert view.assigns.current_user.id == user.id

      {:ok, view, _html} = live(conn, ~p"/sessions/new")
      assert view.assigns.current_user.id == user.id
    end

    test "session is cleared after logout", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/sessions")
      assert html =~ "Your Sessions"

      # Simulate logout
      conn = delete(conn, ~p"/users/sign_out")
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/sessions")
    end
  end
end
