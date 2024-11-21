#!/bin/bash
set -e

echo "Initializing web assets..."

# 确保在项目根目录的 assets 文件夹中
cd assets

# 初始化 npm 项目
npm init -y

# 安装依赖
npm install --save-dev \
    tailwindcss \
    @tailwindcss/forms \
    @tailwindcss/typography \
    @tailwindcss/aspect-ratio \
    postcss \
    autoprefixer \
    esbuild

# 初始化 tailwind 配置
npx tailwindcss init -p

# 修改 tailwind.config.js
cat > tailwind.config.js << 'EOL'
module.exports = {
  content: [
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
EOL

echo "Web assets initialized successfully!" 