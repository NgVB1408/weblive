#!/bin/bash

# 🚀 SCRIPT TRIỂN KHAI NHANH - CHỈ CẦN CHẠY 1 LỆNH
# Chạy: bash quick-deploy.sh

echo "🎯 TRIỂN KHAI NHANH DỰ ÁN LIVESTREAM BETTING"
echo "============================================="

# Di chuyển vào thư mục dự án
cd /root/weblive

# Tạo .env nhanh
cat > .env << 'EOF'
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin
NODE_ENV=production
PORT=5000
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024
CORS_ORIGIN=http://160.187.246.155:3000
SOCKET_CORS_ORIGIN=http://160.187.246.155:3000
ADMIN_CORS_ORIGIN=http://160.187.246.155:3001
EOF

# Mở ports
ufw allow 3000 3001 5000 80 443 2>/dev/null || true

# Dừng cũ và khởi động mới
docker-compose down 2>/dev/null || true
docker-compose up -d --build

echo "⏳ Chờ services khởi động..."
sleep 20

echo "✅ HOÀN TẤT!"
echo "🌐 Frontend: http://160.187.246.155:3000"
echo "🔧 Admin: http://160.187.246.155:3001"
echo "🔌 API: http://160.187.246.155:5000"
