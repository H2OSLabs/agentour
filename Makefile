.PHONY: help install init doc format test clean dev build db.setup db.reset check backup update run

# 默认目标：显示帮助信息
help:
	@echo "Available targets:"
	@echo "  install    - Install system dependencies"
	@echo "  init      - Initialize project (WARNING: This will overwrite existing files)"
	@echo "  update    - Update project dependencies"
	@echo "  doc       - Generate documentation"
	@echo "  format    - Format code"
	@echo "  test      - Run tests with coverage"
	@echo "  clean     - Clean generated files"
	@echo "  dev       - Start development server"
	@echo "  build     - Build for production"
	@echo "  db.setup  - Setup database"
	@echo "  db.reset  - Reset database (WARNING: This will delete all data)"
	@echo "  check     - Run code quality checks"
	@echo "  backup    - Backup current configuration"
	@echo "  run       - Start Phoenix server (default: dev mode, use MIX_ENV=prod for production)"

# 检查是否存在必要的命令
REQUIRED_CMDS := bash git
$(foreach cmd,$(REQUIRED_CMDS),\
    $(if $(shell command -v $(cmd) 2> /dev/null),\
        ,\
        $(error Please install $(cmd) first)))

# 安装所有依赖
install:
	@echo "Installing dependencies..."
	@bash scripts/install_dep.sh

# 初始化项目的mix、poetry和web依赖
init:
	@echo "Updating dependencies..."
	@echo "Updating Mix dependencies..."
	@cd agentour && mix deps.update --all
	@cd agentour && mix deps.clean --unused
	@cd agentour && MIX_ENV=dev mix deps.get
	@echo "Updating Python dependencies..."
	@cd agentour/priv/python && poetry update
	@echo "Updating Node.js dependencies..."
	@cd agentour/assets && npm update
	@echo "Dependencies updated successfully!"

# 生成文档
doc:
	@echo "Checking documentation dependencies..."
	@cd agentour && mix deps.get
	@cd agentour/priv/python && poetry install
	@echo "Generating documentation..."
	@cd agentour && mix docs
	@cd agentour/priv/python && poetry run sphinx-build -b html docs/source docs/build

# 格式化代码
format:
	@echo "Formatting code..."
	@cd agentour && mix format
	@cd agentour/priv/python && poetry run black .
	@cd agentour/priv/python && poetry run isort .
	@cd agentour/assets && npm run format

# 运行测试
test:
	@echo "Running tests..."
	@cd agentour && MIX_ENV=test mix deps.get
	@cd agentour && MIX_ENV=test mix compile --warnings-as-errors
	@cd agentour && MIX_ENV=test mix test
	@cd agentour && MIX_ENV=test mix coveralls
	@cd agentour/priv/python && poetry run pytest --cov=. --cov-report=html
	@cd agentour/assets && npm test

# 清理生成的文件
clean:
	@echo "WARNING: This will remove all generated files and dependencies."
	@read -p "Are you sure you want to continue? [y/N] " confirm; \
	if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
		echo "Aborted."; \
		exit 1; \
	fi
	@cd agentour && mix clean
	@cd agentour && rm -rf _build deps doc priv/static
	@cd agentour/priv/python && poetry env remove --all
	@cd agentour/assets && rm -rf node_modules

# 开发服务器
dev:
	@echo "Starting development server..."
	@cd agentour && mix deps.get
	@cd agentour && mix ecto.migrate
	@cd agentour && mix phx.server

# 生产环境构建
build:
	@echo "Building for production..."
	@cd agentour && MIX_ENV=prod mix deps.get --only prod
	@cd agentour && MIX_ENV=prod mix compile
	@cd agentour && MIX_ENV=prod mix assets.deploy
	@cd agentour/priv/python && poetry install --no-dev


# 代码质量检查
check:
	@echo "Running code quality checks..."
	@cd agentour && mix deps.get
	@cd agentour && mix compile --warnings-as-errors
	@cd agentour && mix credo --strict
	@cd agentour && mix dialyzer
	@cd agentour/priv/python && poetry run mypy .
	@cd agentour/priv/python && poetry run pylint .
	@cd agentour/assets && npm run lint


# 更新项目依赖
update:
	@echo "Updating dependencies..."
	@echo "Updating Mix dependencies..."
	@cd agentour && mix deps.update --all
	@cd agentour && mix deps.clean --unused
	@cd agentour && mix deps.get
	@echo "Updating Python dependencies..."
	@cd agentour/priv/python && poetry update
	@echo "Updating Node.js dependencies..."
	@cd agentour/assets && npm update
	@echo "Dependencies updated successfully!"

# 运行服务器 (默认dev模式)
run:
	@echo "Starting Phoenix server in $(MIX_ENV:=dev) mode..."
	@cd agentour && MIX_ENV=$(MIX_ENV:=dev) mix deps.get
	@cd agentour && MIX_ENV=$(MIX_ENV:=dev) mix ecto.migrate
	@cd agentour && MIX_ENV=$(MIX_ENV:=dev) mix phx.server