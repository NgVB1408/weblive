#!/bin/bash

# 🔍 SCRIPT KIỂM TRA TRIỂN KHAI HOÀN CHỈNH
# Chạy script này để kiểm tra tất cả tính năng

echo "🔍 KIỂM TRA TRIỂN KHAI HOÀN CHỈNH"
echo "================================="

# Kiểm tra thư mục dự án
echo "📁 Kiểm tra thư mục dự án..."
if [ -d "weblive" ]; then
    cd weblive
    echo "✅ Đã vào thư mục dự án: $(pwd)"
else
    echo "❌ Không tìm thấy thư mục dự án"
    exit 1
fi

# Kiểm tra Docker
echo "🐳 Kiểm tra Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Docker chưa được cài đặt"
fi

if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose: $(docker-compose --version)"
else
    echo "❌ Docker Compose chưa được cài đặt"
fi

# Kiểm tra containers
echo "📊 Kiểm tra containers..."
docker-compose ps

# Kiểm tra logs
echo "📋 Kiểm tra logs..."
echo "=== MONGODB LOGS ==="
docker-compose logs --tail=5 mongodb

echo "=== BACKEND LOGS ==="
docker-compose logs --tail=5 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=5 frontend

echo "=== DASHBOARD LOGS ==="
docker-compose logs --tail=5 dashboard-admin

# Test endpoints
echo "🔌 Test endpoints..."
echo "Testing MongoDB..."
timeout 10 docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" 2>/dev/null && echo "✅ MongoDB OK" || echo "❌ MongoDB lỗi"

echo "Testing Backend Health..."
timeout 10 curl -s http://localhost:5000/health && echo "✅ Backend Health OK" || echo "❌ Backend Health lỗi"

echo "Testing Backend API..."
timeout 10 curl -s http://localhost:5000/api/v1/auth/profile && echo "✅ Backend API OK" || echo "❌ Backend API lỗi"

echo "Testing Frontend..."
timeout 10 curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
timeout 10 curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

# Kiểm tra ports
echo "🔌 Kiểm tra ports..."
netstat -tlnp | grep -E ":(3000|3001|5000|27017)" || echo "❌ Một số ports không mở"

# Kiểm tra Nginx
echo "🌐 Kiểm tra Nginx..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx đang chạy"
    nginx -t && echo "✅ Nginx config OK" || echo "❌ Nginx config lỗi"
else
    echo "❌ Nginx không chạy"
fi

# Kiểm tra domain
echo "🌐 Kiểm tra domain..."
echo "Testing devvinny.fun..."
timeout 10 curl -s http://devvinny.fun | head -1 && echo "✅ Domain devvinny.fun OK" || echo "❌ Domain devvinny.fun lỗi"

echo "Testing admin.devvinny.fun..."
timeout 10 curl -s http://admin.devvinny.fun | head -1 && echo "✅ Domain admin.devvinny.fun OK" || echo "❌ Domain admin.devvinny.fun lỗi"

echo "Testing api.devvinny.fun..."
timeout 10 curl -s http://api.devvinny.fun/health && echo "✅ Domain api.devvinny.fun OK" || echo "❌ Domain api.devvinny.fun lỗi"

# Kiểm tra file cấu hình
echo "📄 Kiểm tra file cấu hình..."
if [ -f ".env" ]; then
    echo "✅ File .env tồn tại"
    echo "📋 Nội dung .env:"
    cat .env
else
    echo "❌ File .env không tồn tại"
fi

if [ -f "frontend/.env" ]; then
    echo "✅ File frontend/.env tồn tại"
else
    echo "❌ File frontend/.env không tồn tại"
fi

if [ -f "dashboard-admin/.env" ]; then
    echo "✅ File dashboard-admin/.env tồn tại"
else
    echo "❌ File dashboard-admin/.env không tồn tại"
fi

# Kiểm tra disk space
echo "💾 Kiểm tra dung lượng..."
df -h

# Kiểm tra RAM
echo "🧠 Kiểm tra RAM..."
free -h

# Kiểm tra processes
echo "⚙️ Kiểm tra processes..."
ps aux | grep -E "(node|mongod|nginx)" | grep -v grep

echo ""
echo "✅ KIỂM TRA HOÀN TẤT!"
echo "===================="
echo ""
echo "🌐 URLs để test:"
echo "• Frontend: http://localhost:3000"
echo "• Admin: http://localhost:3001"
echo "• API: http://localhost:5000"
echo "• Health: http://localhost:5000/health"
echo ""
echo "🌐 Domain URLs:"
echo "• Frontend: https://devvinny.fun"
echo "• Admin: https://admin.devvinny.fun"
echo "• API: https://api.devvinny.fun"
echo "• Giao diện dv6666.net: https://devvinny.fun/integrate-dv6666.html"
echo ""
echo "📋 Nếu có lỗi, chạy:"
echo "docker-compose logs -f"
echo ""
echo "🔄 Để restart:"
echo "docker-compose restart"
