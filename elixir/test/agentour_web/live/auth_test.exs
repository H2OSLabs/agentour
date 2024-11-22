defmodule AgentourWeb.AuthTest do
  use AgentourWeb.ConnCase
  import Phoenix.LiveViewTest

  @valid_attrs %{
    email: "test@example.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    name: "Test User"
  }

  describe "registration" do
    test "renders registration page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/register")
      assert html =~ "Register for an account"
    end

    test "redirects to login page with valid registration", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/register")

      view
      |> form("#registration_form", user: @valid_attrs)
      |> render_submit()

      flash = assert_redirect(view, "/login")
      assert flash["info"] =~ "Account created successfully!"
    end

    test "shows error with invalid email format", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/register")

      invalid_attrs = %{@valid_attrs | email: "invalid-email"}
      view
      |> form("#registration_form", user: invalid_attrs)
      |> render_submit()

      assert view
             |> element("#registration_form")
             |> render() =~ "must have the @ sign and no spaces"
    end

    test "shows error with weak password", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/register")

      invalid_attrs = %{@valid_attrs | password: "weak", password_confirmation: "weak"}
      view
      |> form("#registration_form", user: invalid_attrs)
      |> render_submit()

      rendered = element(view, "#registration_form") |> render()
      assert rendered =~ "should be at least 8 character(s)"
      assert rendered =~ "at least one upper case character"
      assert rendered =~ "at least one symbol"
    end

    test "shows error when passwords don't match", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/register")

      invalid_attrs = %{@valid_attrs | password_confirmation: "DifferentPassword123!"}
      view
      |> form("#registration_form", user: invalid_attrs)
      |> render_submit()

      assert element(view, "#registration_form")
             |> render() =~ "does not match confirmation"
    end

    test "shows error for duplicate email", %{conn: conn} do
      # First registration
      {:ok, view1, _html} = live(conn, ~p"/register")
      view1
      |> form("#registration_form", user: @valid_attrs)
      |> render_submit()

      # Second registration with same email
      {:ok, view2, _html} = live(conn, ~p"/register")
      duplicate_attrs = %{@valid_attrs | name: "Another User"}
      view2
      |> form("#registration_form", user: duplicate_attrs)
      |> render_submit()

      assert element(view2, "#registration_form")
             |> render() =~ "has already been taken"
    end
  end

  describe "login" do
    setup %{conn: conn} do
      # Register a user first
      {:ok, view, _html} = live(build_conn(), ~p"/register")
      view
      |> form("#registration_form", user: @valid_attrs)
      |> render_submit()

      conn = 
        conn
        |> init_test_session(%{})
        |> fetch_flash()

      {:ok, conn: conn}
    end

    test "renders login page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/login")
      assert html =~ "Sign in to your account"
    end

    test "successful login redirects and sets session", %{conn: conn} do
      # Submit login form
      conn = post(conn, ~p"/auth/login", %{
        "email" => @valid_attrs.email,
        "password" => @valid_attrs.password
      })

      # Verify redirect
      assert redirected_to(conn) == "/sessions"
      assert get_flash(conn, :info) =~ "Welcome back!"

      # Verify session
      assert get_session(conn, "current_user_id")

      # Follow redirect and verify protected page access
      conn = 
        conn
        |> recycle()
        |> init_test_session(%{"current_user_id" => get_session(conn, "current_user_id")})
        |> fetch_flash()
        |> get("/sessions")

      assert html_response(conn, 200)
      refute get_flash(conn, :error)
    end

    test "unsuccessful login with wrong password", %{conn: conn} do
      conn = post(conn, ~p"/auth/login", %{
        "email" => @valid_attrs.email,
        "password" => "wrong_password"
      })

      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) =~ "Invalid email or password"
      refute get_session(conn, "current_user_id")
    end

    test "unsuccessful login with non-existent email", %{conn: conn} do
      conn = post(conn, ~p"/auth/login", %{
        "email" => "nonexistent@example.com",
        "password" => @valid_attrs.password
      })

      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) =~ "Invalid email or password"
      refute get_session(conn, "current_user_id")
    end

    test "accessing protected page redirects to login", %{conn: conn} do
      conn = get(conn, "/sessions")
      
      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) =~ "You must log in"
    end

    test "logout clears session and redirects", %{conn: conn} do
      # Login first
      conn = post(conn, ~p"/auth/login", %{
        "email" => @valid_attrs.email,
        "password" => @valid_attrs.password
      })

      # Then logout
      conn = 
        conn
        |> recycle()
        |> init_test_session(%{"current_user_id" => get_session(conn, "current_user_id")})
        |> fetch_flash()
        |> get(~p"/auth/logout")

      assert redirected_to(conn) == "/login"
      refute get_session(conn, "current_user_id")

      # Verify can't access protected pages after logout
      conn = 
        conn
        |> recycle()
        |> fetch_flash()
        |> get("/sessions")

      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :error) =~ "You must log in"
    end

    test "session persistence across requests", %{conn: conn} do
      # Login
      conn = post(conn, ~p"/auth/login", %{
        "email" => @valid_attrs.email,
        "password" => @valid_attrs.password
      })
      
      user_id = get_session(conn, "current_user_id")
      assert user_id

      # Access multiple protected pages with same session
      conn = 
        conn
        |> recycle()
        |> init_test_session(%{"current_user_id" => user_id})
        |> fetch_flash()
        |> get("/sessions")

      assert html_response(conn, 200)
      assert get_session(conn, "current_user_id") == user_id

      conn = 
        conn
        |> recycle()
        |> init_test_session(%{"current_user_id" => user_id})
        |> fetch_flash()
        |> get("/profile")

      assert html_response(conn, 200)
      assert get_session(conn, "current_user_id") == user_id
    end
  end

  describe "logout" do
    test "redirects to login page and clears session", %{conn: conn} do
      # First login
      {:ok, view, _html} = live(conn, ~p"/login")
      view
      |> form("#login_form", %{
        email: @valid_attrs.email,
        password: @valid_attrs.password
      })
      |> render_submit()

      conn = get(conn, ~p"/auth/logout")
      assert redirected_to(conn) == "/login"

      # Try accessing protected route after logout
      conn = get(conn, ~p"/sessions")
      assert redirected_to(conn) == "/login"
    end
  end
end
