defmodule AgentourWeb.AgentLive.Edit do
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
     |> assign(:page_title, "Edit Agent")
     |> assign(:agent, Agents.get_agent!(id))}
  end

  @impl true
  def handle_info({AgentourWeb.AgentLive.FormComponent, {:saved, agent}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/agents/#{agent}")}
  end
end
