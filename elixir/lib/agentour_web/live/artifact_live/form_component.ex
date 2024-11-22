defmodule AgentourWeb.ArtifactLive.FormComponent do
  use AgentourWeb, :live_component

  alias Agentour.Artifacts

  @impl true
  def update(%{artifact: artifact} = assigns, socket) do
    changeset = Artifacts.change_artifact(artifact)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"artifact" => artifact_params}, socket) do
    changeset =
      socket.assigns.artifact
      |> Artifacts.change_artifact(artifact_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"artifact" => artifact_params}, socket) do
    save_artifact(socket, socket.assigns.action, artifact_params)
  end

  defp save_artifact(socket, :edit, artifact_params) do
    case Artifacts.update_artifact(socket.assigns.artifact, artifact_params) do
      {:ok, _artifact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artifact updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_artifact(socket, :new, artifact_params) do
    case Artifacts.create_artifact(artifact_params) do
      {:ok, _artifact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artifact created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage artifact records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="artifact-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:content]} type="text" label="Content" />
        <.input field={@form[:metadata]} type="text" label="Metadata" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Artifact</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
