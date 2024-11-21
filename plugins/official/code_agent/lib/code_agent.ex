defmodule Agentour.Plugins.CodeAgent do
  @behaviour Agentour.Plugins.AgentBehaviour

  def init(opts) do
    # 初始化代码生成器
    {:ok, %{model: opts[:model] || "gpt-4"}}
  end

  def handle_message({:generate, prompt}, state) do
    case generate_code(prompt, state.model) do
      {:ok, code} -> {:reply, {:ok, code}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  defp generate_code(prompt, model) do
    # 调用 Python 代码生成器
    Agentour.Python.API.CodeGen.generate(prompt, model: model)
  end
end
