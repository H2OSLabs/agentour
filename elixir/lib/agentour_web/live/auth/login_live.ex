defmodule AgentourWeb.Auth.LoginLive do
  use AgentourWeb, :live_view
  alias Agentour.Accounts

  def mount(_params, _session, socket) do
    socket = assign_new(socket, :current_user, fn -> nil end)

    if socket.assigns.current_user do
      {:ok,
       socket
       |> redirect(to: "/sessions")}
    else
      {:ok,
       socket
       |> assign(:form, to_form(%{"email" => "", "password" => ""}))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to your account
        <:subtitle>
          Don't have an account?
          <.link navigate={"/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" phx-submit="login">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> redirect(to: ~p"/sessions")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password")
         |> assign(:form, to_form(%{"email" => email, "password" => ""}))}
    end
  end
end
