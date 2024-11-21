defmodule AgentourWeb.Auth.RegisterLive do
  use AgentourWeb, :live_view
  alias Agentour.Accounts

  def mount(_params, _session, socket) do
    socket = assign_new(socket, :current_user, fn -> nil end)

    if socket.assigns.current_user do
      {:ok,
       socket
       |> redirect(to: "/sessions")}
    else
      changeset = 
        %Accounts.User{}
        |> Accounts.User.registration_changeset(%{})
        |> Map.put(:action, :validate)

      {:ok,
       socket
       |> assign(:form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already have an account?
          <.link navigate={"/login"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
        <.input field={@form[:email]} type="email" label="Email" required phx-debounce="blur" />
        <.input field={@form[:name]} type="text" label="Name" required phx-debounce="blur" />
        <.input
          field={@form[:password]}
          type="password"
          label="Password"
          required
          phx-debounce="blur"
        />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
          phx-debounce="blur"
        />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">
            Create an account <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.User.registration_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully!")
         |> redirect(to: "/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
