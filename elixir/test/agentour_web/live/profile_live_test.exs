defmodule AgentourWeb.ProfileLiveTest do
  use AgentourWeb.ConnCase
  import Phoenix.LiveViewTest
  import AgentourWeb.AuthHelpers
  alias Agentour.Accounts

  @valid_user_attrs %{
    email: "test@example.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    name: "Test User"
  }

  describe "unauthenticated access" do
    test "redirects to login page when accessing profile page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/profile")
    end
  end

  describe "authenticated access" do
    setup %{conn: conn} do
      {:ok, conn: conn} |> register_and_log_in_user()
    end

    test "renders profile page successfully", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/profile")
      assert html =~ "test@example.com"
      assert html =~ "Test User"
    end
  end
end
