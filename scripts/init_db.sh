#!/bin/bash
set -e

echo "Initializing PostgreSQL database for development..."

# 加载环境变量
if [ -f "../SECRETS" ]; then
    source ../SECRETS
else
    echo "Error: SECRETS file not found!"
    exit 1
fi

# 检查 PostgreSQL 是否运行
pg_isready &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: PostgreSQL is not running!"
    echo "Please start PostgreSQL first:"
    echo "  brew services start postgresql@14"
    exit 1
fi

# 创建数据库用户
echo "Creating database user..."
psql postgres -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';" || echo "User already exists"

# 创建数据库
echo "Creating database..."
createdb -O $POSTGRES_USER $POSTGRES_DB || echo "Database already exists"

# 授予所有权限
echo "Granting privileges..."
psql -d $POSTGRES_DB -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"

echo "Database initialization completed successfully!"
