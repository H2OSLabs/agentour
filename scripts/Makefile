.PHONY: help init 

# 默认目标：显示帮助信息
help:
	@echo "Available targets:"
	@echo "  init      - Initialize project (WARNING: This will overwrite existing files)"

init:
	@echo "WARNING: This will initialize a new project and may overwrite existing files."
	@echo "Make sure you have backed up any important files."
	@read -p "Are you sure you want to continue? [y/N] " confirm; \
	if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
		echo "Aborted."; \
		exit 1; \
	fi
	@echo "Creating backup..."
	@$(MAKE) backup
	@echo "Initializing project..."
	@bash scripts/init_mix.sh
	@bash scripts/init_poetry.sh
	@bash scripts/init_web.sh
	@bash scripts/post_init.sh
	@bash scripts/gen_schema.sh