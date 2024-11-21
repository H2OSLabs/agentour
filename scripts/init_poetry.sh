#!/bin/bash
set -e

echo "Initializing Python environment..."

# 确保在项目根目录
cd python

# 初始化 poetry 项目
poetry init \
    --name "agentour-python" \
    --description "Python components for Agentour" \
    --author "Agentour Team" \
    --python "^3.11" \
    --dev-dependency "pytest" \
    --dev-dependency "black" \
    --dev-dependency "isort" \
    --dev-dependency "mypy" \
    --dev-dependency "sphinx" \
    --dev-dependency "sphinx-rtd-theme" \
    --no-interaction

# 创建虚拟环境并安装依赖
poetry install

echo "Python environment initialized successfully!" 