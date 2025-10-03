#!/bin/bash

# 🚀 SCRIPT TRIỂN KHAI HOÀN CHỈNH - TỪ A ĐẾN Z
# Chạy script này để triển khai toàn bộ dự án

echo "🚀 TRIỂN KHAI HOÀN CHỈNH DỰ ÁN LIVESTREAM BETTING"
echo "================================================"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Vui lòng chạy với quyền root: sudo bash deploy-complete.sh"
    exit 1
fi

# Cập nhật hệ thống
echo "📦 Cập nhật hệ thống..."
apt update -y
apt upgrade -y

# Cài đặt các package cần thiết
echo "📦 Cài đặt các package cần thiết..."
apt install -y curl wget git nginx certbot python3-certbot-nginx ufw

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

# Clone repository
echo "📥 Clone repository..."
if [ -d "/root/weblive" ]; then
    echo "📁 Thư mục đã tồn tại, cập nhật code..."
    cd /root/weblive
    git pull origin main
else
    echo "📁 Clone repository mới..."
    cd /root
    git clone https://github.com/NgVB1408/weblive.git
    cd /root/weblive
fi

# Tạo file .env
echo "⚙️ Tạo file .env..."
cat > .env << 'EOF'
# Database
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin

# Server
NODE_ENV=production
PORT=5000

# JWT - Production keys
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024-very-secure
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024-very-secure

# CORS - Domain
CORS_ORIGIN=https://devvinny.fun
SOCKET_CORS_ORIGIN=https://devvinny.fun
ADMIN_CORS_ORIGIN=https://admin.devvinny.fun
EOF

# Tạo file cấu hình cho frontend và dashboard
echo "📝 Tạo file cấu hình..."

# Frontend .env
mkdir -p frontend
cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_SOCKET_URL=https://api.devvinny.fun
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
EOF

# Dashboard .env
mkdir -p dashboard-admin
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
echo "🔨 Build Docker images..."
docker-compose build --no-cache

echo "🚀 Khởi động services..."
docker-compose up -d

# Chờ services khởi động
echo "⏳ Chờ services khởi động..."
sleep 30

# Cấu hình Nginx
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

# Tạo scripts quản lý
echo "📝 Tạo scripts quản lý..."

cat > start.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose up -d
echo "✅ Tất cả services đã được khởi động!"
echo "🌐 Frontend: https://devvinny.fun"
echo "🔧 Admin: https://admin.devvinny.fun"
echo "🔌 API: https://api.devvinny.fun"
EOF

cat > stop.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose down
echo "🛑 Tất cả services đã được dừng!"
EOF

cat > restart.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose restart
echo "🔄 Tất cả services đã được khởi động lại!"
EOF

cat > logs.sh << 'EOF'
#!/bin/bash
cd /root/weblive
docker-compose logs -f
EOF

cat > status.sh << 'EOF'
#!/bin/bash
cd /root/weblive
echo "📊 Trạng thái services:"
docker-compose ps
echo ""
echo "🌐 URLs:"
echo "Frontend: https://devvinny.fun"
echo "Admin: https://admin.devvinny.fun"
echo "API: https://api.devvinny.fun"
EOF

cat > update.sh << 'EOF'
#!/bin/bash
cd /root/weblive
echo "📥 Cập nhật code từ GitHub..."
git pull origin main
echo "🔄 Khởi động lại services..."
docker-compose down
docker-compose up -d --build
echo "✅ Cập nhật hoàn tất!"
EOF

cat > ssl.sh << 'EOF'
#!/bin/bash
echo "🔒 Cài đặt SSL Certificate..."
certbot --nginx -d devvinny.fun -d www.devvinny.fun -d admin.devvinny.fun -d api.devvinny.fun
echo "✅ SSL đã được cài đặt!"
EOF

# Cấp quyền thực thi
chmod +x start.sh stop.sh restart.sh logs.sh status.sh update.sh ssl.sh

# Kiểm tra trạng thái
echo "📊 Kiểm tra trạng thái..."
docker-compose ps

echo ""
echo "🎉 TRIỂN KHAI HOÀN TẤT!"
echo "======================"
echo ""
echo "📱 Truy cập ứng dụng:"
echo "🌐 Frontend: https://devvinny.fun"
echo "🔧 Admin: https://admin.devvinny.fun"
echo "🔌 API: https://api.devvinny.fun"
echo ""
echo "🛠️ Scripts quản lý:"
echo "• ./start.sh    - Khởi động services"
echo "• ./stop.sh     - Dừng services"
echo "• ./restart.sh  - Khởi động lại services"
echo "• ./logs.sh     - Xem logs"
echo "• ./status.sh   - Kiểm tra trạng thái"
echo "• ./update.sh   - Cập nhật code"
echo "• ./ssl.sh      - Cài đặt SSL"
echo ""
echo "🔒 Để cài đặt SSL, chạy: ./ssl.sh"
echo "📋 Kiểm tra trạng thái: ./status.sh"
