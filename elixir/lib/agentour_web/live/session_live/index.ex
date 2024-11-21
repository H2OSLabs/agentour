defmodule AgentourWeb.SessionLive.Index do
  use AgentourWeb, :live_view
  alias Agentour.Sessions

  def mount(_params, _session, socket) do
    if socket.assigns[:current_user] do
      sessions = Sessions.list_user_sessions(socket.assigns.current_user)
      {:ok, assign(socket, sessions: sessions)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must be logged in to access this page")
       |> redirect(to: ~p"/login")}
    end
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Sessions")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Session")
    |> assign(:session, %Sessions.Session{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Session")
    |> assign(:session, Sessions.get_session!(id))
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8" id="session-list">
      <div class="flex items-center justify-between">
        <.header>
          Your Sessions
          <:subtitle>Manage your collaboration sessions</:subtitle>
        </.header>

        <.link navigate={~p"/sessions/new"} class="rounded-lg bg-zinc-900 px-4 py-2 text-sm font-semibold text-white hover:bg-zinc-700">
          New Session
        </.link>
      </div>

      <div class="flex items-center justify-between">
        <div class="text-sm text-zinc-600">
          Logged in as <%= @current_user.email %>
        </div>
      </div>

      <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <%= for session <- @sessions do %>
          <div class="relative rounded-lg border p-6 hover:border-zinc-400">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold"><%= session.name %></h3>
              <span class={"px-2 py-1 text-xs font-medium rounded-full #{if session.status == "active", do: "bg-green-100 text-green-800", else: "bg-zinc-100 text-zinc-800"}"}>
                <%= session.status %>
              </span>
            </div>

            <p class="mt-2 text-sm text-zinc-600">
              <%= session.description %>
            </p>

            <div class="mt-4 flex items-center gap-4">
              <div class="flex-1"></div>

              <.link
                navigate={~p"/sessions/#{session}/edit"}
                class="rounded-lg bg-zinc-100 px-3 py-2 text-sm font-semibold hover:bg-zinc-200"
              >
                Edit
              </.link>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
