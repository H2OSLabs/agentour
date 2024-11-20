插件系统的核心文件示例：
1. 插件行为定义：
```elixir
defmodule Agentour.Plugins.AgentBehaviour do
  @callback init(opts :: keyword()) :: {:ok, state :: term()} | {:error, reason :: term()}
  
  @callback handle_message(message :: term(), state :: term()) :: 
    {:reply, response :: term(), new_state :: term()} |
    {:noreply, new_state :: term()}

  @callback terminate(reason :: term(), state :: term()) :: term()

  @optional_callbacks terminate: 2
end
```
2. 插件注册中心：
```elixir
defmodule Agentour.Plugins.Registry do
  use GenServer

  # 插件类型
  @type plugin_type :: :agent | :artifact | :view

  # 插件信息结构
  defmodule PluginInfo do
    defstruct [:id, :type, :module, :config, :state]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def register_plugin(type, module, config) do
    GenServer.call(__MODULE__, {:register, type, module, config})
  end

  def get_plugin(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def list_plugins(type) do
    GenServer.call(__MODULE__, {:list, type})
  end
end
```

3. 插件加载器：
```elixir
defmodule Agentour.Plugins.Loader do
  require Logger
  alias Agentour.Plugins.Registry

  def load_all do
    # 加载官方插件
    load_official_plugins()
    # 加载社区插件
    load_community_plugins()
  end

  defp load_official_plugins do
    Path.wildcard("plugins/official/*/manifest.json")
    |> Enum.each(&load_plugin/1)
  end

  defp load_community_plugins do
    Path.wildcard("plugins/community/*/manifest.json")
    |> Enum.each(&load_plugin/1)
  end

  defp load_plugin(manifest_path) do
    with {:ok, manifest} <- File.read(manifest_path),
         {:ok, config} <- Jason.decode(manifest),
         :ok <- validate_manifest(config),
         :ok <- compile_plugin(config),
         :ok <- register_plugin(config) do
      Logger.info("Successfully loaded plugin: #{config["name"]}")
    else
      error ->
        Logger.error("Failed to load plugin from #{manifest_path}: #{inspect(error)}")
    end
  end
end
```

4. 示例插件配置
```json
{
  "id": "code_agent",
  "name": "Code Generation Agent",
  "version": "1.0.0",
  "type": "agent",
  "description": "An AI agent for code generation and review",
  "author": "Agentour Team",
  "license": "MIT",
  "elixir": {
    "module": "Agentour.Plugins.CodeAgent",
    "dependencies": {
      "openai": "~> 0.5.0"
    }
  },
  "python": {
    "module": "code_generator",
    "requirements": [
      "openai==1.0.0",
      "transformers==4.30.0"
    ]
  },
  "assets": {
    "components": ["CodeEditor", "ReviewPanel"],
    "styles": ["code_agent.css"]
  }
}
```

5. 示例插件实现：
code_agent.ex
```elixir
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
```


我建议将插件系统独立出来，创建一个专门的 `plugins` 目录。以下是更新后的插件系统结构：

````plaintext
agentour/
├── lib/                    # 核心系统代码
├── plugins/               # 插件系统根目录
│   ├── manifest.json     # 插件系统配置清单
│   │
│   ├── core/            # 核心插件定义
│   │   ├── behaviours/  # 插件行为定义
│   │   │   ├── agent_plugin.ex      # Agent 插件行为
│   │   │   ├── artifact_plugin.ex   # Artifact 插件行为
│   │   │   └── view_plugin.ex       # 视图插件行为
│   │   │
│   │   ├── registry.ex  # 插件注册中心
│   │   └── loader.ex    # 插件加载器
│   │
│   ├── official/        # 官方插件
│   │   ├── code_agent/  # 示例：代码生成 Agent
│   │   │   ├── manifest.json   # 插件配置
│   │   │   ├── mix.exs        # 插件依赖
│   │   │   ├── lib/          # Elixir 代码
│   │   │   │   └── code_agent.ex
│   │   │   ├── python/       # Python 代码
│   │   │   │   └── code_generator.py
│   │   │   └── assets/       # 前端资源
│   │   │       ├── components/
│   │   │       └── styles/
│   │   │
│   │   └── markdown_artifact/  # 示例：Markdown 编辑器
│   │       ├── manifest.json
│   │       ├── mix.exs
│   │       ├── lib/
│   │       └── assets/
│   │
│   └── community/      # 社区插件目录
       └── example_plugin/
           ├── manifest.json
           ├── mix.exs
           └── ...
````

插件系统的核心文件示例：

1. 插件行为定义：

````elixir:plugins/core/behaviours/agent_plugin.ex
defmodule Agentour.Plugins.AgentBehaviour do
  @callback init(opts :: keyword()) :: {:ok, state :: term()} | {:error, reason :: term()}
  
  @callback handle_message(message :: term(), state :: term()) :: 
    {:reply, response :: term(), new_state :: term()} |
    {:noreply, new_state :: term()}

  @callback terminate(reason :: term(), state :: term()) :: term()

  @optional_callbacks terminate: 2
end
````

2. 插件注册中心：

````elixir:plugins/core/registry.ex
defmodule Agentour.Plugins.Registry do
  use GenServer

  # 插件类型
  @type plugin_type :: :agent | :artifact | :view

  # 插件信息结构
  defmodule PluginInfo do
    defstruct [:id, :type, :module, :config, :state]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def register_plugin(type, module, config) do
    GenServer.call(__MODULE__, {:register, type, module, config})
  end

  def get_plugin(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def list_plugins(type) do
    GenServer.call(__MODULE__, {:list, type})
  end
end
````

3. 插件加载器：

````elixir:plugins/core/loader.ex
defmodule Agentour.Plugins.Loader do
  require Logger
  alias Agentour.Plugins.Registry

  def load_all do
    # 加载官方插件
    load_official_plugins()
    # 加载社区插件
    load_community_plugins()
  end

  defp load_official_plugins do
    Path.wildcard("plugins/official/*/manifest.json")
    |> Enum.each(&load_plugin/1)
  end

  defp load_community_plugins do
    Path.wildcard("plugins/community/*/manifest.json")
    |> Enum.each(&load_plugin/1)
  end

  defp load_plugin(manifest_path) do
    with {:ok, manifest} <- File.read(manifest_path),
         {:ok, config} <- Jason.decode(manifest),
         :ok <- validate_manifest(config),
         :ok <- compile_plugin(config),
         :ok <- register_plugin(config) do
      Logger.info("Successfully loaded plugin: #{config["name"]}")
    else
      error ->
        Logger.error("Failed to load plugin from #{manifest_path}: #{inspect(error)}")
    end
  end
end
````

4. 示例插件配置：

````json:plugins/official/code_agent/manifest.json
{
  "id": "code_agent",
  "name": "Code Generation Agent",
  "version": "1.0.0",
  "type": "agent",
  "description": "An AI agent for code generation and review",
  "author": "Agentour Team",
  "license": "MIT",
  "elixir": {
    "module": "Agentour.Plugins.CodeAgent",
    "dependencies": {
      "openai": "~> 0.5.0"
    }
  },
  "python": {
    "module": "code_generator",
    "requirements": [
      "openai==1.0.0",
      "transformers==4.30.0"
    ]
  },
  "assets": {
    "components": ["CodeEditor", "ReviewPanel"],
    "styles": ["code_agent.css"]
  }
}
````

5. 示例插件实现：

````elixir:plugins/official/code_agent/lib/code_agent.ex
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
````

主要特点：

1. **插件类型**：
   - Agent 插件：定义新的 Agent 行为
   - Artifact 插件：定义新的文档类型和处理方式
   - View 插件：定义新的展示方式

2. **插件结构**：
   - 每个插件都是一个独立的项目
   - 包含 Elixir、Python 和前端代码
   - 统一的配置和依赖管理

3. **插件管理**：
   - 插件注册和发现机制
   - 版本控制和依赖管理
   - 插件生命周期管理

4. **安全性**：
   - 插件沙箱环境
   - 资源使用限制
   - 权限控制系统

这样的插件系统允许：
- 用户轻松扩展系统功能
- 保持核心系统的稳定性
- 支持多语言开发
- 便于分发和管理
