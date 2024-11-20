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
