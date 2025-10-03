#!/bin/bash

# 🌐 SCRIPT CẤU HÌNH DOMAIN devvinny.fun
# Chạy script này sau khi đã triển khai dự án

echo "🌐 CẤU HÌNH DOMAIN devvinny.fun"
echo "==============================="

# Cài đặt Nginx nếu chưa có
if ! command -v nginx &> /dev/null; then
    echo "📦 Cài đặt Nginx..."
    apt update
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
else
    echo "✅ Nginx đã được cài đặt"
fi

# Cài đặt Certbot cho SSL
echo "🔒 Cài đặt Certbot cho SSL..."
apt install certbot python3-certbot-nginx -y

# Tạo cấu hình Nginx
echo "⚙️ Tạo cấu hình Nginx..."
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
echo "🔗 Kích hoạt site..."
ln -sf /etc/nginx/sites-available/devvinny.fun /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test cấu hình Nginx
echo "🧪 Test cấu hình Nginx..."
nginx -t

# Restart Nginx
echo "🔄 Khởi động lại Nginx..."
systemctl restart nginx

# Cài đặt SSL Certificate
echo "🔒 Cài đặt SSL Certificate..."
echo "⚠️  Lưu ý: Cần đảm bảo domain đã trỏ về server trước khi chạy lệnh này"
echo "📋 Chạy lệnh sau để cài đặt SSL:"
echo "certbot --nginx -d devvinny.fun -d www.devvinny.fun -d admin.devvinny.fun -d api.devvinny.fun"

echo ""
echo "✅ CẤU HÌNH DOMAIN HOÀN TẤT!"
echo "============================="
echo ""
echo "🌐 URLs:"
echo "• Frontend: http://devvinny.fun"
echo "• Admin: http://admin.devvinny.fun"
echo "• API: http://api.devvinny.fun"
echo ""
echo "🔒 Để cài đặt SSL, chạy:"
echo "certbot --nginx -d devvinny.fun -d www.devvinny.fun -d admin.devvinny.fun -d api.devvinny.fun"
echo ""
echo "📋 Kiểm tra DNS:"
echo "nslookup devvinny.fun"
