#!/bin/bash
set -e

echo "Checking and installing system dependencies..."

# 检查并安装包管理器
install_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "Homebrew already installed"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! command -v apt-get &> /dev/null; then
            echo "Error: This script requires apt-get package manager"
            exit 1
        fi
    fi
}

# 检查并安装 pipx
install_pipx() {
    if ! command -v pipx &> /dev/null; then
        echo "Installing pipx..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install pipx
            pipx ensurepath
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # 确保有基础的 Python 和 pip
            sudo apt-get install -y python3-venv python3-pip
            python3 -m pip install --user pipx
            python3 -m pipx ensurepath
        fi
        # 重新加载环境变量以确保 pipx 命令可用
        source ~/.bashrc
    else
        echo "pipx already installed"
    fi
}

# 检查并安装 poetry
install_poetry() {
    if ! command -v poetry &> /dev/null; then
        echo "Installing Poetry using pipx..."
        pipx install poetry
    else
        echo "Poetry already installed"
        poetry --version
    fi
}

# 检查并安装 Elixir 相关工具
install_elixir_tools() {
    if ! command -v mix &> /dev/null; then
        echo "Installing Elixir..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install elixir
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y elixir erlang-dev erlang-nox
        fi
    else
        echo "Elixir already installed"
        elixir --version
    fi

    echo "Installing/Updating hex and rebar..."
    mix local.hex --force
    mix local.rebar --force
}

# 检查并安装 Node.js
install_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install node
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y nodejs npm
        fi
    else
        echo "Node.js already installed"
        node --version
    fi
}

# 检查并安装 PostgreSQL
install_postgresql() {
    if ! command -v psql &> /dev/null; then
        echo "Installing PostgreSQL..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install postgresql
            brew services start postgresql
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y postgresql postgresql-contrib
            sudo systemctl start postgresql
        fi
    else
        echo "PostgreSQL already installed"
        psql --version
    fi
}

# 检查并安装其他依赖
install_other_deps() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! command -v inotifywait &> /dev/null; then
            echo "Installing inotify-tools..."
            sudo apt-get install -y inotify-tools
        else
            echo "inotify-tools already installed"
        fi
    fi
}

# 主安装流程
main() {
    echo "Starting installation process..."
    
    # 更新系统包信息
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Updating package information..."
        sudo apt-get update
    fi

    install_package_manager
    install_pipx
    install_poetry
    install_elixir_tools
    install_nodejs
    install_postgresql
    install_other_deps

    echo "All system dependencies installed successfully!"
}

# 运行主安装流程
main