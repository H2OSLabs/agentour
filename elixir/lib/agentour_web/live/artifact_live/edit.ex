defmodule AgentourWeb.ArtifactLive.Edit do
  use AgentourWeb, :live_view

  alias Agentour.Artifacts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Edit Artifact")
     |> assign(:artifact, Artifacts.get_artifact!(id))}
  end

  @impl true
  def handle_info({AgentourWeb.ArtifactLive.FormComponent, {:saved, artifact}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/artifacts/#{artifact}")}
  end
end
