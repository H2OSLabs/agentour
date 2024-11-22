defmodule AgentourWeb.AuthController do
  use AgentourWeb, :controller
  alias Agentour.Accounts
  alias AgentourWeb.AuthPlug

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account created successfully!")
        |> redirect(to: "/login")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Error creating account: #{error_messages(changeset)}")
        |> redirect(to: "/register")
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session("current_user_id", user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: "/sessions")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/login")
  end

  defp error_messages(changeset) do
    Enum.map_join(changeset.errors, ", ", fn {field, {message, _}} ->
      "#{field} #{message}"
    end)
  end
end
