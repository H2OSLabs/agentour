defmodule AgentourWeb.AgentLiveTest do
  use AgentourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Agentour.AgentsFixtures
  import AgentourWeb.AuthHelpers
  import Agentour.AccountsFixtures

  @create_attrs %{name: "some name", type: "chat"}
  @update_attrs %{name: "some updated name", type: "chat"}
  @invalid_attrs %{name: nil, type: nil}

  describe "unauthenticated access" do
    test "redirects to login page when accessing index", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/agents")
    end

    test "redirects to login page when accessing show", %{conn: conn} do
      user = user_fixture()
      agent = agent_fixture(%{user: user})
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/agents/#{agent}")
    end
  end

  describe "authenticated access" do
    setup %{conn: conn} do
      {:ok, conn: conn} |> register_and_log_in_user()
    end

    test "lists all agents", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/agents")
      assert html =~ "Listing Agents"
    end

    test "saves new agent", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/agents")

      assert index_live |> element("a", "New Agent") |> render_click() =~
               "New Agent"

      assert_patch(index_live, ~p"/agents/new")

      assert index_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#agent-form", agent: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Agent created successfully"
      assert html =~ "some name"
    end

    test "updates agent in listing", %{conn: conn, user: user} do
      agent = agent_fixture(%{user: user})
      {:ok, index_live, _html} = live(conn, ~p"/agents")

      assert index_live |> element("#agents-#{agent.id} a", "Edit") |> render_click() =~
               "Edit Agent"

      assert_patch(index_live, ~p"/agents/#{agent}/edit")

      assert index_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#agent-form", agent: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Agent updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes agent in listing", %{conn: conn, user: user} do
      agent = agent_fixture(%{user: user})
      {:ok, index_live, _html} = live(conn, ~p"/agents")

      assert index_live |> element("#agents-#{agent.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#agent-#{agent.id}")
    end

    test "displays agent", %{conn: conn, user: user} do
      agent = agent_fixture(%{user: user})
      {:ok, _show_live, html} = live(conn, ~p"/agents/#{agent}")

      assert html =~ "Show Agent"
      assert html =~ agent.name
    end

    test "updates agent within modal", %{conn: conn, user: user} do
      agent = agent_fixture(%{user: user})
      {:ok, show_live, _html} = live(conn, ~p"/agents/#{agent}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Agent"

      assert_patch(show_live, ~p"/agents/#{agent}/edit")

      assert show_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#agent-form", agent: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Agent updated successfully"
      assert html =~ "some updated name"
    end
  end
end
