#!/bin/bash
set -e

echo "Initializing Phoenix project..."
# 安装Phoenix
mix archive.install hex phx_new

# 创建新的 Phoenix 项目
mix phx.new agentour --database postgres --no-install

# cd agentour

# # 修改 mix.exs，添加额外依赖
# cat >> mix.exs << 'EOL'

#   defp deps do
#     [
#       {:electric, "~> 0.8.1"},
#       {:pyrlang, "~> 1.0"},
#       {:salad_ui, "0.13.1"},
#       {:ex_doc, "~> 0.34", only: :dev, runtime: false},
#       {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
#       {:excoveralls, "~> 0.10", only: :test},
#       {:ex_machina, "~> 2.7.0", only: :test},
#       {:mock, "~> 0.3.0", only: :test}
#     ]
#   end
# EOL

# # 获取依赖
# mix deps.get

# # 创建数据库
# mix ecto.create

# echo "Phoenix project initialized successfully!" 