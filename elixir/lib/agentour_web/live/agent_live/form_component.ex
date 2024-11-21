defmodule AgentourWeb.AgentLive.FormComponent do
  use AgentourWeb, :live_component

  alias Agentour.Agents
  alias Agentour.Agents.Agent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage agent records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@changeset}
        id="agent-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@changeset[:name]} type="text" label="Name" required />
        <.input
          field={@changeset[:type]}
          type="select"
          label="Type"
          options={[
            {"Assistant", "assistant"},
            {"User", "user"},
            {"System", "system"},
            {"Tool", "tool"}
          ]}
          required
        />
        <.input
          field={@changeset[:capabilities]}
          type="text"
          label="Capabilities (comma-separated)"
          value={Enum.join(@changeset[:capabilities].value || [], ", ")}
        />
        <.input
          field={@changeset[:metadata]}
          type="textarea"
          label="Metadata (JSON)"
          value={Jason.encode!(@changeset[:metadata].value || %{}, pretty: true)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Agent</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{agent: agent} = assigns, socket) do
    changeset = Agents.change_agent(agent)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"agent" => agent_params}, socket) do
    changeset =
      socket.assigns.agent
      |> Agents.change_agent(parse_agent_params(agent_params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"agent" => agent_params}, socket) do
    save_agent(socket, socket.assigns.action, parse_agent_params(agent_params))
  end

  defp save_agent(socket, :edit, agent_params) do
    case Agents.update_agent(socket.assigns.agent, agent_params) do
      {:ok, _agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Agent updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_agent(socket, :new, agent_params) do
    case Agents.create_agent(Map.put(agent_params, "user_id", socket.assigns.current_user.id)) do
      {:ok, _agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Agent created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp parse_agent_params(params) do
    params
    |> parse_capabilities()
    |> parse_metadata()
  end

  defp parse_capabilities(%{"capabilities" => capabilities} = params) when is_binary(capabilities) do
    capabilities = 
      capabilities
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(params, "capabilities", capabilities)
  end

  defp parse_capabilities(params), do: params

  defp parse_metadata(%{"metadata" => metadata} = params) when is_binary(metadata) do
    case Jason.decode(metadata) do
      {:ok, decoded} -> Map.put(params, "metadata", decoded)
      {:error, _} -> params
    end
  end

  defp parse_metadata(params), do: params
end
