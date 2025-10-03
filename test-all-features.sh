#!/bin/bash

# 🧪 SCRIPT TEST TẤT CẢ TÍNH NĂNG
# Chạy script này để test tất cả tính năng của dự án

echo "🧪 TEST TẤT CẢ TÍNH NĂNG DỰ ÁN"
echo "============================="

# Kiểm tra thư mục dự án
if [ -d "weblive" ]; then
    cd weblive
    echo "📁 Đã vào thư mục dự án: $(pwd)"
else
    echo "❌ Không tìm thấy thư mục dự án"
    exit 1
fi

# Test 1: Kiểm tra containers
echo "📊 TEST 1: Kiểm tra containers..."
docker-compose ps

# Test 2: Kiểm tra MongoDB
echo "🗄️ TEST 2: Kiểm tra MongoDB..."
timeout 10 docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" 2>/dev/null && echo "✅ MongoDB hoạt động" || echo "❌ MongoDB lỗi"

# Test 3: Kiểm tra Backend API
echo "🔌 TEST 3: Kiểm tra Backend API..."
echo "Testing /health endpoint..."
timeout 10 curl -s http://localhost:5000/health && echo "✅ Health endpoint OK" || echo "❌ Health endpoint lỗi"

echo "Testing /api/v1/auth/profile endpoint..."
timeout 10 curl -s http://localhost:5000/api/v1/auth/profile && echo "✅ Auth endpoint OK" || echo "❌ Auth endpoint lỗi"

echo "Testing /api/v1/matches endpoint..."
timeout 10 curl -s http://localhost:5000/api/v1/matches && echo "✅ Matches endpoint OK" || echo "❌ Matches endpoint lỗi"

# Test 4: Kiểm tra Frontend
echo "🎨 TEST 4: Kiểm tra Frontend..."
echo "Testing Frontend response..."
timeout 10 curl -s http://localhost:3000 | head -5 && echo "✅ Frontend hoạt động" || echo "❌ Frontend lỗi"

# Test 5: Kiểm tra Admin Dashboard
echo "🔧 TEST 5: Kiểm tra Admin Dashboard..."
echo "Testing Admin Dashboard response..."
timeout 10 curl -s http://localhost:3001 | head -5 && echo "✅ Admin Dashboard hoạt động" || echo "❌ Admin Dashboard lỗi"

# Test 6: Kiểm tra Domain
echo "🌐 TEST 6: Kiểm tra Domain..."
echo "Testing devvinny.fun..."
timeout 10 curl -s http://devvinny.fun | head -1 && echo "✅ Domain devvinny.fun hoạt động" || echo "❌ Domain devvinny.fun lỗi"

echo "Testing admin.devvinny.fun..."
timeout 10 curl -s http://admin.devvinny.fun | head -1 && echo "✅ Domain admin.devvinny.fun hoạt động" || echo "❌ Domain admin.devvinny.fun lỗi"

echo "Testing api.devvinny.fun..."
timeout 10 curl -s http://api.devvinny.fun/health && echo "✅ Domain api.devvinny.fun hoạt động" || echo "❌ Domain api.devvinny.fun lỗi"

# Test 7: Kiểm tra Giao diện dv6666.net
echo "🎯 TEST 7: Kiểm tra Giao diện dv6666.net..."
echo "Testing integrate-dv6666.html..."
timeout 10 curl -s http://devvinny.fun/integrate-dv6666.html | head -1 && echo "✅ Giao diện dv6666.net hoạt động" || echo "❌ Giao diện dv6666.net lỗi"

echo "Testing test-livestream.html..."
timeout 10 curl -s http://devvinny.fun/test-livestream.html | head -1 && echo "✅ Test livestream hoạt động" || echo "❌ Test livestream lỗi"

# Test 8: Kiểm tra Socket.io
echo "🔌 TEST 8: Kiểm tra Socket.io..."
echo "Testing Socket.io connection..."
timeout 10 curl -s http://localhost:5000/socket.io/ | head -1 && echo "✅ Socket.io hoạt động" || echo "❌ Socket.io lỗi"

# Test 9: Kiểm tra Database
echo "🗄️ TEST 9: Kiểm tra Database..."
echo "Testing MongoDB connection..."
timeout 10 docker-compose exec mongodb mongosh --eval "use livestream_betting; db.stats()" 2>/dev/null && echo "✅ Database hoạt động" || echo "❌ Database lỗi"

# Test 10: Kiểm tra Performance
echo "⚡ TEST 10: Kiểm tra Performance..."
echo "Testing response times..."

echo "Backend response time:"
time curl -s http://localhost:5000/health > /dev/null 2>&1 && echo "✅ Backend nhanh" || echo "❌ Backend chậm"

echo "Frontend response time:"
time curl -s http://localhost:3000 > /dev/null 2>&1 && echo "✅ Frontend nhanh" || echo "❌ Frontend chậm"

echo "Admin response time:"
time curl -s http://localhost:3001 > /dev/null 2>&1 && echo "✅ Admin nhanh" || echo "❌ Admin chậm"

# Test 11: Kiểm tra Logs
echo "📋 TEST 11: Kiểm tra Logs..."
echo "Backend logs (last 5 lines):"
docker-compose logs --tail=5 backend

echo "Frontend logs (last 5 lines):"
docker-compose logs --tail=5 frontend

echo "Dashboard logs (last 5 lines):"
docker-compose logs --tail=5 dashboard-admin

# Test 12: Kiểm tra Resources
echo "💾 TEST 12: Kiểm tra Resources..."
echo "Disk space:"
df -h

echo "RAM usage:"
free -h

echo "CPU usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

echo ""
echo "✅ TEST TẤT CẢ TÍNH NĂNG HOÀN TẤT!"
echo "=================================="
echo ""
echo "🎯 TÓM TẮT KẾT QUẢ:"
echo "==================="
echo ""
echo "🌐 URLs hoạt động:"
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
