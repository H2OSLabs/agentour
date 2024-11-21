defmodule AgentourWeb.AgentLive.New do
  use AgentourWeb, :live_view

  alias Agentour.Agents
  alias Agentour.Agents.Agent

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:agent, %Agent{})
     |> assign(:patch, ~p"/agents")}
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_user, socket.assigns.current_user)}
  end

  @impl true
  def handle_event("save", %{"agent" => agent_params}, socket) do
    case Agents.create_agent(Map.put(agent_params, "user_id", socket.assigns.current_user.id)) do
      {:ok, _agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Agent created successfully")
         |> push_navigate(to: ~p"/agents")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info({AgentourWeb.AgentLive.FormComponent, {:saved, agent}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/agents")}
  end
end
