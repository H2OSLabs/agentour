defmodule AgentourWeb.ArtifactLiveTest do
  use AgentourWeb.ConnCase
  import Phoenix.LiveViewTest
  import Agentour.ArtifactsFixtures
  import AgentourWeb.AuthHelpers
  import Agentour.AccountsFixtures

  describe "unauthenticated access" do
    setup %{conn: conn} do
      user = user_fixture()
      artifact = artifact_fixture(%{user: user})
      %{conn: conn, artifact: artifact}
    end

    test "redirects to login page when accessing show page", %{conn: conn, artifact: artifact} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/artifacts/#{artifact}")
    end

    test "redirects to login page when accessing edit page", %{conn: conn, artifact: artifact} do
      assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/artifacts/#{artifact}/edit")
    end
  end

  describe "authenticated access" do
    setup %{conn: conn} do
      {:ok, conn: conn} |> register_and_log_in_user()
    end

    test "shows artifact details", %{conn: conn, user: user} do
      artifact = artifact_fixture(%{user: user})
      {:ok, _show_live, html} = live(conn, ~p"/artifacts/#{artifact}")

      assert html =~ artifact.name
      assert html =~ artifact.type
    end

    test "updates existing artifact", %{conn: conn, user: user} do
      artifact = artifact_fixture(%{user: user})
      {:ok, show_live, _html} = live(conn, ~p"/artifacts/#{artifact}/edit")

      assert show_live
             |> form("#artifact-form", artifact: %{name: "Updated Name"})
             |> render_submit()

      assert_patch(show_live, ~p"/artifacts/#{artifact}")

      html = render(show_live)
      assert html =~ "Updated Name"
    end
  end
end
