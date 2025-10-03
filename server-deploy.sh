#!/bin/bash

# 🚀 SCRIPT TỰ ĐỘNG TRIỂN KHAI DỰ ÁN TRÊN SERVER
# Chạy script này trên server: bash server-deploy.sh

echo "🎯 BẮT ĐẦU TRIỂN KHAI DỰ ÁN LIVESTREAM BETTING PLATFORM"
echo "=================================================="

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Vui lòng chạy với quyền root: sudo bash server-deploy.sh"
    exit 1
fi

# Cập nhật hệ thống
echo "📦 Cập nhật hệ thống..."
apt update -y
apt upgrade -y

# Cài đặt Docker nếu chưa có
echo "🐳 Kiểm tra và cài đặt Docker..."
if ! command -v docker &> /dev/null; then
    echo "Cài đặt Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl start docker
    systemctl enable docker
else
    echo "✅ Docker đã được cài đặt"
fi

# Cài đặt Docker Compose nếu chưa có
echo "🐳 Kiểm tra và cài đặt Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "Cài đặt Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
else
    echo "✅ Docker Compose đã được cài đặt"
fi

# Di chuyển vào thư mục dự án
echo "📁 Di chuyển vào thư mục dự án..."
cd /root/weblive

# Tạo file .env cho server
echo "⚙️ Tạo file cấu hình .env..."
cat > .env << 'EOF'
# Database
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin

# Server
NODE_ENV=production
PORT=5000

# JWT - Production keys
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024-very-secure
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024-very-secure

# CORS - Server IP
CORS_ORIGIN=http://160.187.246.155:3000
SOCKET_CORS_ORIGIN=http://160.187.246.155:3000
ADMIN_CORS_ORIGIN=http://160.187.246.155:3001
EOF

echo "✅ File .env đã được tạo"

# Mở firewall ports
echo "🔥 Cấu hình firewall..."
ufw --force enable
ufw allow 22
ufw allow 3000
ufw allow 3001
ufw allow 5000
ufw allow 80
ufw allow 443
echo "✅ Firewall đã được cấu hình"

# Dừng các containers cũ nếu có
echo "🛑 Dừng các containers cũ..."
docker-compose down 2>/dev/null || true

# Build và khởi động services
echo "🔨 Build Docker images..."
docker-compose build --no-cache

echo "🚀 Khởi động tất cả services..."
docker-compose up -d

# Chờ services khởi động
echo "⏳ Chờ services khởi động..."
sleep 30

# Kiểm tra trạng thái
echo "📊 Kiểm tra trạng thái services..."
docker-compose ps

# Kiểm tra logs
echo "📋 Kiểm tra logs..."
echo "=== BACKEND LOGS ==="
docker-compose logs --tail=10 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=10 frontend

echo "=== ADMIN LOGS ==="
docker-compose logs --tail=10 dashboard-admin

echo "=== MONGODB LOGS ==="
docker-compose logs --tail=10 mongodb

# Tạo scripts quản lý
echo "📝 Tạo scripts quản lý..."

# Script khởi động
cat > start.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose up -d
echo "✅ Tất cả services đã được khởi động!"
echo "🌐 Frontend: http://160.187.246.155:3000"
echo "🔧 Admin: http://160.187.246.155:3001"
echo "🔌 API: http://160.187.246.155:5000"
EOF

# Script dừng
cat > stop.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose down
echo "🛑 Tất cả services đã được dừng!"
EOF

# Script restart
cat > restart.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose restart
echo "🔄 Tất cả services đã được khởi động lại!"
EOF

# Script logs
cat > logs.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose logs -f
EOF

# Script status
cat > status.sh << 'EOF'
#!/bin/bash
cd /root/weblive
echo "📊 Trạng thái services:"
docker-compose ps
echo ""
echo "🌐 URLs:"
echo "Frontend: http://160.187.246.155:3000"
echo "Admin: http://160.187.246.155:3001"
echo "API: http://160.187.246.155:5000"
EOF

# Cấp quyền thực thi
chmod +x start.sh stop.sh restart.sh logs.sh status.sh

echo ""
echo "🎉 TRIỂN KHAI HOÀN TẤT!"
echo "======================"
echo ""
echo "📱 Truy cập ứng dụng:"
echo "🌐 Frontend (Người dùng): http://160.187.246.155:3000"
echo "🔧 Admin Dashboard: http://160.187.246.155:3001"
echo "🔌 Backend API: http://160.187.246.155:5000"
echo ""
echo "🛠️ Scripts quản lý:"
echo "• ./start.sh    - Khởi động tất cả services"
echo "• ./stop.sh     - Dừng tất cả services"
echo "• ./restart.sh  - Khởi động lại services"
echo "• ./logs.sh     - Xem logs real-time"
echo "• ./status.sh   - Kiểm tra trạng thái"
echo ""
echo "📊 Kiểm tra trạng thái:"
./status.sh
echo ""
echo "✅ Dự án đã sẵn sàng sử dụng!"
