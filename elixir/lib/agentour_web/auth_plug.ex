defmodule AgentourWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias AgentourWeb.Router.Helpers, as: Routes
  alias Agentour.Accounts

  def init(opts), do: opts

  def call(conn, :fetch_current_user) do
    user_id = get_session(conn, "current_user_id")

    cond do
      is_nil(user_id) ->
        assign(conn, :current_user, nil)
      true ->
        case Accounts.get_user_by_id(user_id) do
          nil -> 
            conn
            |> clear_session()
            |> assign(:current_user, nil)
          user -> 
            assign(conn, :current_user, user)
        end
    end
  end

  def call(conn, :ensure_authenticated) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
