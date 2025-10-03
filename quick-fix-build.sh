#!/bin/bash

# 🚀 SCRIPT SỬA LỖI BUILD NHANH
# Chạy script này để sửa lỗi build ngay lập tức

echo "🚀 SỬA LỖI BUILD NHANH"
echo "====================="

# Dừng containers hiện tại
echo "🛑 Dừng containers hiện tại..."
docker-compose down

# Xóa images cũ
echo "🗑️ Xóa images cũ..."
docker system prune -f
docker rmi $(docker images -q) 2>/dev/null || true

# Tạo file cấu hình thiếu
echo "📝 Tạo file cấu hình thiếu..."

# Frontend .env
cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_SOCKET_URL=https://api.devvinny.fun
VITE_APP_NAME=Livestream Betting Platform
EOF

# Dashboard .env
cat > dashboard-admin/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_APP_NAME=Livestream Betting Admin
EOF

# PostCSS configs
cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > dashboard-admin/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Tailwind configs
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
EOF

cat > dashboard-admin/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
EOF

# Build lại với cache
echo "🔨 Build lại với cache..."
docker-compose build --no-cache

# Khởi động services
echo "🚀 Khởi động services..."
docker-compose up -d

# Kiểm tra logs
echo "📋 Kiểm tra logs..."
sleep 10
docker-compose logs --tail=20 frontend
docker-compose logs --tail=20 dashboard-admin

echo ""
echo "✅ HOÀN TẤT!"
echo "Kiểm tra trạng thái: docker-compose ps"
