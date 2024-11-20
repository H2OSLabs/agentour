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
