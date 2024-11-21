defmodule AgentourWeb.AgentLive.Show do
  use AgentourWeb, :live_view

  alias Agentour.Agents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:agent, Agents.get_agent!(id))
     |> assign(:live_action, :show)}
  end

  defp page_title(:show), do: "Show Agent"
  defp page_title(:edit), do: "Edit Agent"
  defp page_title(_), do: "Agent"
end
