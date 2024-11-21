defmodule AgentourWeb.ProfileLive do
  use AgentourWeb, :live_view
  alias Agentour.Accounts

  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      changeset = Accounts.change_user(socket.assigns.current_user)
      {:ok, assign(socket, form: to_form(changeset))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must be logged in to access this page")
       |> redirect(to: ~p"/login")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header>
        Profile Settings
        <:subtitle>Manage your account settings and preferences</:subtitle>
      </.header>

      <div class="mt-8 space-y-8">
        <.simple_form for={@form} id="profile-form" phx-submit="save">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:name]} type="text" label="Name" required />
          <.input
            field={@form[:current_password]}
            name="current_password"
            type="password"
            label="Current Password"
            value={@form[:current_password].value}
            required
          />

          <:actions>
            <.button phx-disable-with="Saving...">Save Changes</.button>
          </:actions>
        </.simple_form>

        <.simple_form for={@form} id="password-form" phx-submit="update_password">
          <.input
            field={@form[:password]}
            type="password"
            label="New Password"
            required
          />
          <.input
            field={@form[:password_confirmation]}
            type="password"
            label="Confirm New Password"
            required
          />

          <:actions>
            <.button phx-disable-with="Changing Password...">Change Password</.button>
          </:actions>
        </.simple_form>

        <div class="pt-8 border-t">
          <.button
            phx-click="delete_account"
            class="bg-red-600 hover:bg-red-700"
            data-confirm="Are you sure you want to delete your account? This action cannot be undone."
          >
            Delete Account
          </.button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"user" => %{"email" => _email, "name" => _name} = params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully")
         |> assign(current_user: user)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating profile")
         |> assign(form: to_form(changeset))}
    end
  end

  def handle_event("delete_account", _params, socket) do
    case Accounts.delete_user(socket.assigns.current_user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account deleted successfully")
         |> redirect(to: ~p"/login")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error deleting account")}
    end
  end
end
