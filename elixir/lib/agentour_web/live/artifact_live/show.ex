defmodule AgentourWeb.ArtifactLive.Show do
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
     |> assign(:page_title, "Show Artifact")
     |> assign(:artifact, Artifacts.get_artifact!(id))}
  end
end
