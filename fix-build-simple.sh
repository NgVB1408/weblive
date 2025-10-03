#!/bin/bash

# 🚀 SCRIPT SỬA LỖI BUILD ĐƠN GIẢN
# Chạy script này để sửa lỗi build một cách đơn giản

echo "🚀 SỬA LỖI BUILD ĐƠN GIẢN"
echo "========================="

# Kiểm tra thư mục hiện tại
echo "📁 Thư mục hiện tại: $(pwd)"
echo "📁 Nội dung:"
ls -la

# Tìm thư mục dự án
if [ -d "/root/weblive" ]; then
    echo "📁 Tìm thấy dự án tại /root/weblive"
    cd /root/weblive
elif [ -d "weblive" ]; then
    echo "📁 Tìm thấy dự án tại ./weblive"
    cd weblive
elif [ -d "frontend" ] && [ -d "dashboard-admin" ]; then
    echo "📁 Đã ở trong thư mục dự án"
else
    echo "❌ Không tìm thấy dự án!"
    echo "📋 Vui lòng clone dự án trước:"
    echo "git clone https://github.com/NgVB1408/weblive.git"
    echo "cd weblive"
    exit 1
fi

echo "📁 Thư mục dự án: $(pwd)"
echo "📁 Nội dung dự án:"
ls -la

# Tạo thư mục nếu chưa có
mkdir -p frontend
mkdir -p dashboard-admin

# Tạo file .env cho frontend
echo "📝 Tạo file .env cho frontend..."
cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_SOCKET_URL=https://api.devvinny.fun
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
EOF

# Tạo file .env cho dashboard-admin
echo "📝 Tạo file .env cho dashboard-admin..."
cat > dashboard-admin/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_APP_NAME=Livestream Betting Admin
VITE_APP_VERSION=1.0.0
EOF

# Tạo postcss.config.js
echo "📝 Tạo postcss.config.js..."
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

# Tạo tailwind.config.js
echo "📝 Tạo tailwind.config.js..."
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

echo "✅ Đã tạo các file cấu hình"
echo ""
echo "🔄 Dừng containers hiện tại..."
docker-compose down 2>/dev/null || true

echo "🔨 Build lại containers..."
docker-compose build --no-cache

echo "🚀 Khởi động containers..."
docker-compose up -d

echo "⏳ Chờ containers khởi động..."
sleep 15

echo "📊 Kiểm tra trạng thái:"
docker-compose ps

echo "📋 Kiểm tra logs nếu cần:"
echo "docker-compose logs frontend"
echo "docker-compose logs dashboard-admin"

echo ""
echo "✅ HOÀN TẤT!"
echo "🌐 Truy cập: https://devvinny.fun"
