defmodule AgentourWeb.SessionLive.New do
  use AgentourWeb, :live_view
  alias Agentour.Sessions

  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok,
       socket
       |> assign(:form, to_form(%{"name" => "", "description" => ""}))}
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
        Create New Session
        <:subtitle>Start a new collaboration session</:subtitle>
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

        <:actions>
          <.button phx-disable-with="Creating...">Create Session</.button>
          <.link
            patch={~p"/sessions"}
            class="rounded-lg px-3 py-2 text-sm font-semibold hover:bg-zinc-100"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"name" => name, "description" => description}, socket) do
    attrs = %{
      name: name,
      description: description,
      owner_id: socket.assigns.current_user.id,
      status: "active"
    }

    case Sessions.create_session(attrs) do
      {:ok, _session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session created successfully")
         |> redirect(to: ~p"/sessions")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating session")
         |> assign(form: to_form(changeset))}
    end
  end
end
