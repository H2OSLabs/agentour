defmodule Agentour.Plugins.AgentBehaviour do
  @callback init(opts :: keyword()) :: {:ok, state :: term()} | {:error, reason :: term()}

  @callback handle_message(message :: term(), state :: term()) ::
    {:reply, response :: term(), new_state :: term()} |
    {:noreply, new_state :: term()}

  @callback terminate(reason :: term(), state :: term()) :: term()

  @optional_callbacks terminate: 2
end
