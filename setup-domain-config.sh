#!/bin/bash

# 🌐 SCRIPT CẤU HÌNH DOMAIN devvinny.fun
# Chạy script này để cấu hình domain

echo "🌐 CẤU HÌNH DOMAIN devvinny.fun"
echo "=============================="

# Kiểm tra thư mục dự án
if [ ! -d "weblive" ]; then
    echo "📥 Clone repository..."
    git clone https://github.com/NgVB1408/weblive.git
    cd weblive
else
    echo "📁 Di chuyển vào thư mục dự án..."
    cd weblive
fi

echo "📁 Thư mục hiện tại: $(pwd)"

# Tạo file .env với domain
echo "⚙️ Tạo file .env với domain..."
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

# Tạo thư mục và file cấu hình cho frontend
echo "📁 Tạo thư mục và file cấu hình..."
mkdir -p frontend
mkdir -p dashboard-admin

# Frontend .env với domain
cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_SOCKET_URL=https://api.devvinny.fun
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
EOF

# Dashboard .env với domain
cat > dashboard-admin/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_APP_NAME=Livestream Betting Admin
VITE_APP_VERSION=1.0.0
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

# Cấu hình Nginx
echo "🌐 Cấu hình Nginx..."
apt update -y
apt install nginx -y

# Tạo cấu hình Nginx
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

# Cấu hình firewall
echo "🔥 Cấu hình firewall..."
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 3000
ufw allow 3001
ufw allow 5000

# Dừng containers cũ
echo "🛑 Dừng containers cũ..."
docker-compose down 2>/dev/null || true

# Build và khởi động
echo "🔨 Build và khởi động services..."
docker-compose build --no-cache

# Khởi động từng service với delay
echo "🚀 Starting MongoDB..."
docker-compose up -d mongodb
sleep 20

echo "🚀 Starting Backend..."
docker-compose up -d backend
sleep 30

echo "🚀 Starting Frontend..."
docker-compose up -d frontend
sleep 20

echo "🚀 Starting Dashboard..."
docker-compose up -d dashboard-admin
sleep 20

# Kiểm tra trạng thái
echo "📊 Kiểm tra trạng thái..."
docker-compose ps

# Test endpoints
echo "🔌 Test endpoints..."
echo "Testing Backend..."
curl -s http://localhost:5000/health && echo "✅ Backend OK" || echo "❌ Backend lỗi"

echo "Testing Frontend..."
curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

# Tạo scripts quản lý
echo "📝 Tạo scripts quản lý..."
cat > start.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose up -d
echo "✅ Services started!"
echo "🌐 Frontend: https://devvinny.fun"
echo "🔧 Admin: https://admin.devvinny.fun"
echo "🔌 API: https://api.devvinny.fun"
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
echo "Frontend: https://devvinny.fun"
echo "Admin: https://admin.devvinny.fun"
echo "API: https://api.devvinny.fun"
EOF

cat > ssl.sh << 'EOF'
#!/bin/bash
echo "🔒 Cài đặt SSL Certificate..."
apt install certbot python3-certbot-nginx -y
certbot --nginx -d devvinny.fun -d www.devvinny.fun -d admin.devvinny.fun -d api.devvinny.fun
echo "✅ SSL đã được cài đặt!"
EOF

chmod +x start.sh stop.sh restart.sh logs.sh status.sh ssl.sh

echo ""
echo "✅ CẤU HÌNH DOMAIN HOÀN TẤT!"
echo "============================"
echo ""
echo "🌐 URLs:"
echo "• Frontend: https://devvinny.fun"
echo "• Admin: https://admin.devvinny.fun"
echo "• API: https://api.devvinny.fun"
echo ""
echo "🛠️ Scripts quản lý:"
echo "• ./start.sh    - Khởi động services"
echo "• ./stop.sh     - Dừng services"
echo "• ./restart.sh  - Khởi động lại services"
echo "• ./logs.sh     - Xem logs"
echo "• ./status.sh   - Kiểm tra trạng thái"
echo "• ./ssl.sh      - Cài đặt SSL"
echo ""
echo "🔒 Để cài đặt SSL, chạy: ./ssl.sh"
echo "📋 Kiểm tra trạng thái: ./status.sh"
