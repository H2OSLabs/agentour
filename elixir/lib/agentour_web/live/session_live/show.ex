defmodule AgentourWeb.SessionLive.Show do
  use AgentourWeb, :live_view
  alias Agentour.Sessions
  alias Agentour.Agents

  def mount(%{"id" => id}, _session, socket) do
    if socket.assigns.current_user do
      session = Sessions.get_session!(id)
      available_agents = Agents.list_user_agents(socket.assigns.current_user)

      {:ok,
       socket
       |> assign(:session, session)
       |> assign(:available_agents, available_agents)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must be logged in to access this page")
       |> redirect(to: ~p"/login")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div class="flex items-center justify-between">
        <.header>
          <%= @session.name %>
          <:subtitle><%= @session.description %></:subtitle>
        </.header>

        <div class="flex items-center gap-4">
          <span class={"px-3 py-1 text-sm font-medium rounded-full #{if @session.status == "active", do: "bg-green-100 text-green-800", else: "bg-zinc-100 text-zinc-800"}"}>
            <%= @session.status %>
          </span>

          <.link
            patch={~p"/sessions/#{@session}/edit"}
            class="rounded-lg bg-zinc-900 px-4 py-2 text-sm font-semibold text-white hover:bg-zinc-700"
          >
            Edit Session
          </.link>
        </div>
      </div>

      <div class="grid gap-8 lg:grid-cols-2">
        <div class="space-y-6">
          <.header class="text-base">
            Participating Agents
            <:subtitle>Agents currently in this session</:subtitle>
          </.header>

          <div class="space-y-4">
            <%= for agent <- @session.agents do %>
              <div class="flex items-center justify-between rounded-lg border p-4">
                <div>
                  <h4 class="font-semibold"><%= agent.name %></h4>
                  <p class="text-sm text-zinc-600"><%= agent.type %></p>
                </div>

                <button
                  phx-click="remove_agent"
                  phx-value-agent_id={agent.id}
                  class="rounded-lg bg-red-50 px-3 py-2 text-sm font-semibold text-red-600 hover:bg-red-100"
                >
                  Remove
                </button>
              </div>
            <% end %>
          </div>
        </div>

        <div class="space-y-6">
          <.header class="text-base">
            Available Agents
            <:subtitle>Add more agents to this session</:subtitle>
          </.header>

          <div class="space-y-4">
            <%= for agent <- @available_agents do %>
              <%= if agent not in @session.agents do %>
                <div class="flex items-center justify-between rounded-lg border p-4">
                  <div>
                    <h4 class="font-semibold"><%= agent.name %></h4>
                    <p class="text-sm text-zinc-600"><%= agent.type %></p>
                  </div>

                  <button
                    phx-click="add_agent"
                    phx-value-agent_id={agent.id}
                    class="rounded-lg bg-zinc-100 px-3 py-2 text-sm font-semibold hover:bg-zinc-200"
                  >
                    Add to Session
                  </button>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("add_agent", %{"agent_id" => agent_id}, socket) do
    session = socket.assigns.session
    agent = Agents.get_agent!(agent_id)

    case Sessions.add_agent_to_session(session, agent) do
      {:ok, updated_session} ->
        {:noreply,
         socket
         |> assign(:session, updated_session)
         |> put_flash(:info, "Agent added successfully")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error adding agent to session")}
    end
  end

  def handle_event("remove_agent", %{"agent_id" => agent_id}, socket) do
    session = socket.assigns.session
    agent = Agents.get_agent!(agent_id)

    case Sessions.remove_agent_from_session(session, agent) do
      {:ok, updated_session} ->
        {:noreply,
         socket
         |> assign(:session, updated_session)
         |> put_flash(:info, "Agent removed successfully")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error removing agent from session")}
    end
  end
end
