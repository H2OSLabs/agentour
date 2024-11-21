defmodule AgentourWeb.InitAssigns do
  import Phoenix.Component

  def on_mount(:current_user, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn ->
      if user_id = session["current_user_id"] do
        Agentour.Accounts.get_user_by_id(user_id)
      end
    end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/login", flash: %{"error" => "You must log in to access this page."})}
    end
  end
end
