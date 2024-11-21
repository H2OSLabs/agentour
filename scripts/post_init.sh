#!/bin/bash
set -e

echo "Running post-initialization tasks..."

# 创建必要的目录结构
mkdir -p \
    plugins/{core/{behaviours,registry},official,community} \
    docs/{elixir,python,assets/{images,css,js}} \
    priv/python/{provider,ml,utils}

# 复制插件系统核心文件
cp -r plugins/core/* lib/agentour/plugins/

# 更新 config/config.exs
cat >> config/config.exs << 'EOL'

config :agentour, Agentour.Plugins,
  directory: "plugins",
  types: [:agent, :artifact, :view]

config :agentour, Agentour.Python,
  python_path: "priv/python",
  requirements_path: "priv/python/requirements.txt"
EOL

# 创建文档
mix docs

# 格式化代码
mix format

echo "Post-initialization tasks completed successfully!" 