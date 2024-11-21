defmodule AgentourWeb.SessionLive.Edit do
  use AgentourWeb, :live_view
  alias Agentour.Sessions

  def mount(%{"id" => id}, _session, socket) do
    if socket.assigns.current_user do
      session = Sessions.get_session!(id)

      {:ok,
       socket
       |> assign(:session, session)
       |> assign(:form, to_form(Map.from_struct(session)))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must be logged in to access this page")
       |> redirect(to: ~p"/login")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <.header>
        Edit Session
        <:subtitle>Update session details</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="session-form"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Session Name" required />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          placeholder="What is this session about?"
        />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[{"Active", "active"}, {"Archived", "archived"}]}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Changes</.button>
          <.link
            patch={~p"/sessions/#{@session}"}
            class="rounded-lg px-3 py-2 text-sm font-semibold hover:bg-zinc-100"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>

      <div class="mt-8">
        <.button
          phx-click="delete"
          class="bg-red-600 hover:bg-red-700"
          data-confirm="Are you sure you want to delete this session? This action cannot be undone."
        >
          Delete Session
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("save", params, socket) do
    case Sessions.update_session(socket.assigns.session, params) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session updated successfully")
         |> redirect(to: ~p"/sessions/#{session}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating session")
         |> assign(form: to_form(changeset))}
    end
  end

  def handle_event("delete", _params, socket) do
    case Sessions.delete_session(socket.assigns.session) do
      {:ok, _session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session deleted successfully")
         |> redirect(to: ~p"/sessions")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error deleting session")}
    end
  end
end
