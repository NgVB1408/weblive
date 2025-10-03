#!/bin/bash

# 🔧 SCRIPT SỬA TẤT CẢ LỖI
# Chạy script này để sửa tất cả lỗi có thể gặp

echo "🔧 SỬA TẤT CẢ LỖI TRIỂN KHAI"
echo "============================"

# Cập nhật hệ thống
echo "📦 Cập nhật hệ thống..."
apt update -y
apt upgrade -y

# Cài đặt các package cần thiết
echo "📦 Cài đặt các package cần thiết..."
apt install -y curl wget git nginx ufw net-tools

# Cài đặt Docker
echo "🐳 Cài đặt Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $USER
else
    echo "✅ Docker đã được cài đặt"
fi

# Cài đặt Docker Compose
echo "🐳 Cài đặt Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
else
    echo "✅ Docker Compose đã được cài đặt"
fi

# Di chuyển vào thư mục dự án
echo "📁 Di chuyển vào thư mục dự án..."
if [ -d "/root/weblive" ]; then
    cd /root/weblive
elif [ -d "weblive" ]; then
    cd weblive
else
    echo "📥 Clone repository..."
    cd /root
    git clone https://github.com/NgVB1408/weblive.git
    cd /root/weblive
fi

echo "📁 Thư mục hiện tại: $(pwd)"

# Dừng tất cả containers
echo "🛑 Dừng tất cả containers..."
docker-compose down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Xóa tất cả images và volumes
echo "🗑️ Xóa tất cả images và volumes..."
docker system prune -af
docker volume prune -f
docker network prune -f

# Tạo file .env
echo "⚙️ Tạo file .env..."
cat > .env << 'EOF'
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin
NODE_ENV=production
PORT=5000
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024-very-secure
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024-very-secure
CORS_ORIGIN=http://localhost:3000
SOCKET_CORS_ORIGIN=http://localhost:3000
ADMIN_CORS_ORIGIN=http://localhost:3001
EOF

# Tạo thư mục và file cấu hình
echo "📁 Tạo thư mục và file cấu hình..."
mkdir -p frontend
mkdir -p dashboard-admin

# Frontend .env
cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_SOCKET_URL=http://localhost:5000
VITE_APP_NAME=Livestream Betting Platform
EOF

# Dashboard .env
cat > dashboard-admin/.env << 'EOF'
VITE_API_BASE_URL=http://localhost:5000/api/v1
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

# Cấu hình firewall
echo "🔥 Cấu hình firewall..."
ufw --force enable
ufw allow 22
ufw allow 3000
ufw allow 3001
ufw allow 5000
ufw allow 27017

# Build lại từ đầu
echo "🔨 Build lại từ đầu..."
docker-compose build --no-cache --pull

# Khởi động từng service với delay
echo "🚀 Khởi động từng service..."

echo "🚀 Starting MongoDB..."
docker-compose up -d mongodb
echo "⏳ Chờ MongoDB khởi động..."
sleep 20

echo "🚀 Starting Backend..."
docker-compose up -d backend
echo "⏳ Chờ Backend khởi động..."
sleep 30

echo "🚀 Starting Frontend..."
docker-compose up -d frontend
echo "⏳ Chờ Frontend khởi động..."
sleep 20

echo "🚀 Starting Dashboard..."
docker-compose up -d dashboard-admin
echo "⏳ Chờ Dashboard khởi động..."
sleep 20

# Kiểm tra trạng thái
echo "📊 Kiểm tra trạng thái..."
docker-compose ps

# Kiểm tra logs
echo "📋 Kiểm tra logs..."
echo "=== MONGODB LOGS ==="
docker-compose logs --tail=10 mongodb

echo "=== BACKEND LOGS ==="
docker-compose logs --tail=10 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=10 frontend

echo "=== DASHBOARD LOGS ==="
docker-compose logs --tail=10 dashboard-admin

# Test endpoints
echo "🔌 Test endpoints..."
echo "Testing MongoDB..."
timeout 10 docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" 2>/dev/null && echo "✅ MongoDB OK" || echo "❌ MongoDB lỗi"

echo "Testing Backend..."
timeout 10 curl -s http://localhost:5000/health && echo "✅ Backend OK" || echo "❌ Backend lỗi"

echo "Testing Frontend..."
timeout 10 curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
timeout 10 curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

# Tạo scripts quản lý
echo "📝 Tạo scripts quản lý..."
cat > start.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose up -d
echo "✅ Services started!"
EOF

cat > stop.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose down
echo "🛑 Services stopped!"
EOF

cat > restart.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose restart
echo "🔄 Services restarted!"
EOF

cat > logs.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose logs -f
EOF

cat > status.sh << 'EOF'
#!/bin/bash
cd /root/weblive
echo "📊 Container Status:"
docker-compose ps
echo ""
echo "🌐 URLs:"
echo "Frontend: http://localhost:3000"
echo "Admin: http://localhost:3001"
echo "API: http://localhost:5000"
EOF

chmod +x start.sh stop.sh restart.sh logs.sh status.sh

echo ""
echo "✅ SỬA LỖI HOÀN TẤT!"
echo "===================="
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
echo "🛠️ Scripts quản lý:"
echo "• ./start.sh    - Khởi động"
echo "• ./stop.sh     - Dừng"
echo "• ./restart.sh  - Khởi động lại"
echo "• ./logs.sh     - Xem logs"
echo "• ./status.sh   - Kiểm tra trạng thái"
echo ""
echo "📋 Nếu vẫn lỗi, chạy:"
echo "docker-compose logs -f"
