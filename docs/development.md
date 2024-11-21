# 开发环境配置指南

本文档将指导你如何设置开发环境。

## 前置要求

1. Python 3.11 或更高版本
2. Poetry（Python 依赖管理工具）
3. PostgreSQL 14 或更高版本

## 安装步骤

### 1. 安装 PostgreSQL

MacOS 用户：
```bash
# 使用 Homebrew 安装 PostgreSQL
brew install postgresql@14

# 启动 PostgreSQL 服务
brew services start postgresql@14
```

Linux 用户：
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql-14

# 启动 PostgreSQL 服务
sudo systemctl start postgresql
```

### 2. 配置 Python 环境

```bash
# 安装 Poetry（如果还没有安装）
curl -sSL https://install.python-poetry.org | python3 -

# 初始化 Python 环境
cd python
poetry install
```

### 3. 初始化数据库

```bash
# 确保 PostgreSQL 服务正在运行
cd scripts
bash init_db.sh
```

## 验证安装

运行以下命令验证环境是否配置正确：

1. 验证数据库连接：
```bash
psql -d agentour_dev -U agentour
```

2. 验证 Python 环境：
```bash
cd python
poetry run python -c "print('Environment is working!')"
```

## 常见问题

1. PostgreSQL 连接错误
   - 确保 PostgreSQL 服务正在运行
   - 检查 SECRETS 文件中的配置是否正确
   - 确保已运行 init_db.sh 脚本

2. Poetry 依赖安装问题
   - 确保使用正确的 Python 版本
   - 尝试删除 poetry.lock 文件后重新安装

## 开发工作流程

1. 激活 Python 虚拟环境：
```bash
cd python
poetry shell
```

2. 运行测试：
```bash
poetry run pytest
```

## 环境变量

项目使用 SECRETS 文件管理敏感配置。确保该文件包含以下配置：

```env
# Database configuration
POSTGRES_USER=agentour
POSTGRES_PASSWORD=agentour_dev
POSTGRES_DB=agentour_dev
DATABASE_URL=postgresql://agentour:agentour_dev@localhost:5432/agentour_dev

# Phoenix configuration
SECRET_KEY_BASE=your_secret_key_here
```

注意：
1. 不要将实际的 SECRETS 文件提交到版本控制系统中
2. 复制 `.env.example` 为 `SECRETS` 并更新配置
3. 确保在运行 Phoenix 应用之前已经加载了环境变量：
   ```bash
   source SECRETS
   mix phx.server
   ```

## Phoenix 应用

1. 首次设置：
   ```bash
   cd elixir
   mix deps.get
   mix ecto.setup
   ```

2. 启动应用：
   ```bash
   # 确保已加载环境变量
   source ../SECRETS
   # 启动服务器
   mix phx.server
   ```
