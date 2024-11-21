defmodule AgentourWeb.AgentLive.Index do
  use AgentourWeb, :live_view

  alias Agentour.Agents
  alias Agentour.Agents.Agent

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns[:current_user] do
      {:ok, assign(socket, :agents, list_agents(socket))}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Listing Agents")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    agent = Agents.get_agent!(id)
    {:ok, _} = Agents.delete_agent(agent)

    {:noreply, assign(socket, :agents, list_agents(socket))}
  end

  defp list_agents(socket) do
    Agents.list_agents_by_user(socket.assigns.current_user)
  end
end
