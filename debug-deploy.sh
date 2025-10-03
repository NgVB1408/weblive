#!/bin/bash

# 🔍 SCRIPT DEBUG VÀ SỬA LỖI TRIỂN KHAI
# Chạy script này để debug và sửa lỗi

echo "🔍 DEBUG VÀ SỬA LỖI TRIỂN KHAI"
echo "=============================="

# Kiểm tra thư mục hiện tại
echo "📁 Thư mục hiện tại:"
pwd
ls -la

# Kiểm tra Docker
echo "🐳 Kiểm tra Docker:"
if command -v docker &> /dev/null; then
    echo "✅ Docker đã cài đặt: $(docker --version)"
    systemctl status docker --no-pager -l
else
    echo "❌ Docker chưa được cài đặt"
    echo "📦 Cài đặt Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
fi

# Kiểm tra Docker Compose
echo "🐳 Kiểm tra Docker Compose:"
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose đã cài đặt: $(docker-compose --version)"
else
    echo "❌ Docker Compose chưa được cài đặt"
    echo "📦 Cài đặt Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Kiểm tra thư mục dự án
echo "📁 Kiểm tra thư mục dự án:"
if [ -d "/root/weblive" ]; then
    echo "✅ Thư mục dự án tồn tại tại /root/weblive"
    cd /root/weblive
elif [ -d "weblive" ]; then
    echo "✅ Thư mục dự án tồn tại tại ./weblive"
    cd weblive
else
    echo "❌ Không tìm thấy thư mục dự án"
    echo "📥 Clone repository..."
    cd /root
    git clone https://github.com/NgVB1408/weblive.git
    cd /root/weblive
fi

echo "📁 Thư mục dự án hiện tại:"
pwd
ls -la

# Kiểm tra file docker-compose.yml
echo "📄 Kiểm tra docker-compose.yml:"
if [ -f "docker-compose.yml" ]; then
    echo "✅ File docker-compose.yml tồn tại"
    echo "📋 Nội dung docker-compose.yml:"
    head -20 docker-compose.yml
else
    echo "❌ File docker-compose.yml không tồn tại"
    exit 1
fi

# Tạo file .env nếu chưa có
echo "⚙️ Kiểm tra file .env:"
if [ ! -f ".env" ]; then
    echo "📝 Tạo file .env..."
    cat > .env << 'EOF'
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin
NODE_ENV=production
PORT=5000
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024-very-secure
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024-very-secure
CORS_ORIGIN=https://devvinny.fun
SOCKET_CORS_ORIGIN=https://devvinny.fun
ADMIN_CORS_ORIGIN=https://admin.devvinny.fun
EOF
    echo "✅ File .env đã được tạo"
else
    echo "✅ File .env đã tồn tại"
fi

# Tạo thư mục và file cấu hình cho frontend
echo "📁 Tạo thư mục và file cấu hình cho frontend:"
mkdir -p frontend
mkdir -p dashboard-admin

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

echo "✅ Đã tạo các file cấu hình"

# Dừng containers cũ
echo "🛑 Dừng containers cũ..."
docker-compose down 2>/dev/null || true

# Xóa images cũ để build lại
echo "🗑️ Xóa images cũ..."
docker system prune -f
docker rmi $(docker images -q) 2>/dev/null || true

# Build từng service riêng biệt
echo "🔨 Build từng service riêng biệt..."

echo "📦 Building MongoDB..."
docker-compose build mongodb

echo "📦 Building Backend..."
docker-compose build backend

echo "📦 Building Frontend..."
docker-compose build frontend

echo "📦 Building Dashboard..."
docker-compose build dashboard-admin

# Khởi động từng service
echo "🚀 Khởi động từng service..."

echo "🚀 Starting MongoDB..."
docker-compose up -d mongodb
sleep 10

echo "🚀 Starting Backend..."
docker-compose up -d backend
sleep 15

echo "🚀 Starting Frontend..."
docker-compose up -d frontend
sleep 10

echo "🚀 Starting Dashboard..."
docker-compose up -d dashboard-admin
sleep 10

# Kiểm tra trạng thái
echo "📊 Kiểm tra trạng thái containers:"
docker-compose ps

# Kiểm tra logs
echo "📋 Kiểm tra logs:"
echo "=== MONGODB LOGS ==="
docker-compose logs --tail=5 mongodb

echo "=== BACKEND LOGS ==="
docker-compose logs --tail=5 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=5 frontend

echo "=== DASHBOARD LOGS ==="
docker-compose logs --tail=5 dashboard-admin

# Test endpoints
echo "🔌 Test endpoints:"
echo "Testing MongoDB..."
docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" 2>/dev/null && echo "✅ MongoDB OK" || echo "❌ MongoDB lỗi"

echo "Testing Backend..."
curl -s http://localhost:5000/health && echo "✅ Backend OK" || echo "❌ Backend lỗi"

echo "Testing Frontend..."
curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

# Kiểm tra ports
echo "🔌 Kiểm tra ports:"
netstat -tlnp | grep -E ":(3000|3001|5000|27017)" || echo "❌ Một số ports không mở"

# Kiểm tra disk space
echo "💾 Kiểm tra dung lượng:"
df -h

# Kiểm tra RAM
echo "🧠 Kiểm tra RAM:"
free -h

echo ""
echo "✅ DEBUG HOÀN TẤT!"
echo "=================="
echo ""
echo "📊 Trạng thái containers:"
docker-compose ps
echo ""
echo "🌐 URLs để test:"
echo "• Frontend: http://localhost:3000"
echo "• Admin: http://localhost:3001"
echo "• API: http://localhost:5000"
echo "• Health: http://localhost:5000/health"
echo ""
echo "📋 Nếu vẫn lỗi, xem logs chi tiết:"
echo "docker-compose logs -f"
echo ""
echo "🔄 Để restart tất cả:"
echo "docker-compose restart"
