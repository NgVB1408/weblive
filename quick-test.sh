#!/bin/bash

# 🧪 SCRIPT TEST NHANH DỰ ÁN
# Chạy script này để test nhanh dự án

echo "🧪 TEST NHANH DỰ ÁN LIVESTREAM BETTING"
echo "====================================="

# Kiểm tra thư mục
echo "📁 Kiểm tra thư mục hiện tại:"
pwd
ls -la

# Kiểm tra Docker
echo "🐳 Kiểm tra Docker:"
docker --version
docker-compose --version

# Kiểm tra containers
echo "📊 Kiểm tra containers:"
docker-compose ps

# Kiểm tra logs
echo "📋 Kiểm tra logs (10 dòng cuối):"
echo "=== BACKEND LOGS ==="
docker-compose logs --tail=10 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=10 frontend

echo "=== ADMIN LOGS ==="
docker-compose logs --tail=10 dashboard-admin

echo "=== MONGODB LOGS ==="
docker-compose logs --tail=10 mongodb

# Test API endpoints
echo "🔌 Test API endpoints:"
echo "Testing backend health..."
curl -s http://localhost:5000/health || echo "❌ Backend không phản hồi"

echo "Testing frontend..."
curl -s http://localhost:3000 | head -5 || echo "❌ Frontend không phản hồi"

echo "Testing admin..."
curl -s http://localhost:3001 | head -5 || echo "❌ Admin không phản hồi"

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
echo "✅ TEST HOÀN TẤT!"
echo "================="
echo ""
echo "🌐 URLs để test:"
echo "• Frontend: http://localhost:3000"
echo "• Admin: http://localhost:3001"
echo "• API: http://localhost:5000"
echo "• Health: http://localhost:5000/health"
echo ""
echo "📋 Nếu có lỗi, chạy:"
echo "docker-compose logs -f"
echo ""
echo "🔄 Để restart:"
echo "docker-compose restart"
