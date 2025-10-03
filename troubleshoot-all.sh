#!/bin/bash

# 🔍 SCRIPT KIỂM TRA VÀ SỬA LỖI TOÀN DIỆN
# Chạy script này để kiểm tra và sửa tất cả lỗi

echo "🔍 KIỂM TRA VÀ SỬA LỖI TOÀN DIỆN"
echo "================================="

# Kiểm tra thư mục dự án
if [ -d "weblive" ]; then
    cd weblive
    echo "📁 Đã vào thư mục dự án: $(pwd)"
else
    echo "❌ Không tìm thấy thư mục dự án"
    exit 1
fi

# 1. Kiểm tra containers
echo "📊 Kiểm tra containers..."
docker-compose ps

# 2. Kiểm tra logs
echo "📋 Kiểm tra logs..."
echo "=== MONGODB LOGS ==="
docker-compose logs --tail=5 mongodb

echo "=== BACKEND LOGS ==="
docker-compose logs --tail=5 backend

echo "=== FRONTEND LOGS ==="
docker-compose logs --tail=5 frontend

echo "=== DASHBOARD LOGS ==="
docker-compose logs --tail=5 dashboard-admin

# 3. Test endpoints
echo "🔌 Test endpoints..."
echo "Testing Backend Health..."
timeout 10 curl -s http://localhost:5000/health && echo "✅ Backend Health OK" || echo "❌ Backend Health lỗi"

echo "Testing Backend API..."
timeout 10 curl -s http://localhost:5000/api/v1/auth/profile && echo "✅ Backend API OK" || echo "❌ Backend API lỗi"

echo "Testing Frontend..."
timeout 10 curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
timeout 10 curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

# 4. Kiểm tra ports
echo "🔌 Kiểm tra ports..."
netstat -tlnp | grep -E ":(3000|3001|5000|27017)" || echo "❌ Một số ports không mở"

# 5. Kiểm tra Nginx
echo "🌐 Kiểm tra Nginx..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx đang chạy"
    nginx -t && echo "✅ Nginx config OK" || echo "❌ Nginx config lỗi"
else
    echo "❌ Nginx không chạy"
    echo "📦 Cài đặt Nginx..."
    apt update -y
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
fi

# 6. Cấu hình Nginx
echo "🌐 Cấu hình Nginx..."
cat > /etc/nginx/sites-available/devvinny.fun << 'EOF'
# Frontend
server {
    listen 80;
    server_name devvinny.fun www.devvinny.fun;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Admin Dashboard
server {
    listen 80;
    server_name admin.devvinny.fun;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# API Backend
server {
    listen 80;
    server_name api.devvinny.fun;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Kích hoạt site
ln -sf /etc/nginx/sites-available/devvinny.fun /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test và restart Nginx
nginx -t
systemctl restart nginx

# 7. Cấu hình firewall
echo "🔥 Cấu hình firewall..."
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 3000
ufw allow 3001
ufw allow 5000

# 8. Test với IP server
echo "🌐 Test với IP server..."
echo "Testing Frontend với IP..."
timeout 10 curl -s http://160.187.246.155:3000 | head -1 && echo "✅ Frontend IP OK" || echo "❌ Frontend IP lỗi"

echo "Testing Admin với IP..."
timeout 10 curl -s http://160.187.246.155:3001 | head -1 && echo "✅ Admin IP OK" || echo "❌ Admin IP lỗi"

echo "Testing API với IP..."
timeout 10 curl -s http://160.187.246.155:5000/health && echo "✅ API IP OK" || echo "❌ API IP lỗi"

# 9. Kiểm tra domain
echo "🌐 Kiểm tra domain..."
echo "Testing domain devvinny.fun..."
timeout 10 curl -s http://devvinny.fun | head -1 && echo "✅ Domain devvinny.fun OK" || echo "❌ Domain devvinny.fun lỗi"

echo "Testing domain admin.devvinny.fun..."
timeout 10 curl -s http://admin.devvinny.fun | head -1 && echo "✅ Domain admin.devvinny.fun OK" || echo "❌ Domain admin.devvinny.fun lỗi"

echo "Testing domain api.devvinny.fun..."
timeout 10 curl -s http://api.devvinny.fun/health && echo "✅ Domain api.devvinny.fun OK" || echo "❌ Domain api.devvinny.fun lỗi"

# 10. Kiểm tra DNS
echo "🌐 Kiểm tra DNS..."
echo "Testing DNS resolution..."
nslookup devvinny.fun
nslookup admin.devvinny.fun
nslookup api.devvinny.fun

# 11. Restart tất cả services
echo "🔄 Restart tất cả services..."
docker-compose restart

# 12. Kiểm tra cuối cùng
echo "📊 Kiểm tra cuối cùng..."
docker-compose ps

echo ""
echo "✅ KIỂM TRA VÀ SỬA LỖI HOÀN TẤT!"
echo "================================="
echo ""
echo "🌐 URLs để test:"
echo "• Frontend: http://160.187.246.155:3000"
echo "• Admin: http://160.187.246.155:3001"
echo "• API: http://160.187.246.155:5000"
echo "• Health: http://160.187.246.155:5000/health"
echo ""
echo "🌐 Domain URLs (nếu DNS đã trỏ):"
echo "• Frontend: http://devvinny.fun"
echo "• Admin: http://admin.devvinny.fun"
echo "• API: http://api.devvinny.fun"
echo ""
echo "📋 Nếu vẫn lỗi, chạy:"
echo "docker-compose logs -f"
echo ""
echo "🔄 Để restart:"
echo "docker-compose restart"
