defmodule AgentourWeb.ArtifactLive.FormComponent do
  use AgentourWeb, :live_component

  alias Agentour.Artifacts

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
        <.input field={@form[:name]} type="text" label="Name" required />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          options={[
            {"Text", "text"},
            {"Code", "code"},
            {"File", "file"}
          ]}
          required
        />
        <.input
          field={@form[:content]}
          type={if @form[:type].value == "text", do: "textarea", else: "text"}
          label="Content"
          required
        />
        <.input
          field={@form[:metadata]}
          type="textarea"
          label="Metadata (JSON)"
          value={Jason.encode!(@form[:metadata].value || %{}, pretty: true)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Artifact</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{artifact: artifact} = assigns, socket) do
    changeset = Artifacts.change_artifact(artifact)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"artifact" => artifact_params}, socket) do
    # Parse metadata JSON
    artifact_params = update_metadata(artifact_params)

    changeset =
      socket.assigns.artifact
      |> Artifacts.change_artifact(artifact_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"artifact" => artifact_params}, socket) do
    # Parse metadata JSON
    artifact_params = update_metadata(artifact_params)

    save_artifact(socket, socket.assigns.action, artifact_params)
  end

  defp save_artifact(socket, :edit, artifact_params) do
    case Artifacts.update_artifact(socket.assigns.artifact, artifact_params) do
      {:ok, artifact} ->
        notify_parent({:saved, artifact})

        {:noreply,
         socket
         |> put_flash(:info, "Artifact updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp update_metadata(%{"metadata" => metadata} = params) when is_binary(metadata) do
    case Jason.decode(metadata) do
      {:ok, decoded} -> %{params | "metadata" => decoded}
      {:error, _} -> params
    end
  end

  defp update_metadata(params), do: params
end
