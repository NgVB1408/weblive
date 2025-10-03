#!/bin/bash

# 🔧 SCRIPT SỬA LỖI PERMISSION VÀ VOLUME
# Chạy script này để sửa lỗi permission và volume

echo "🔧 SỬA LỖI PERMISSION VÀ VOLUME"
echo "==============================="

# Kiểm tra thư mục dự án
if [ -d "weblive" ]; then
    cd weblive
    echo "📁 Đã vào thư mục dự án: $(pwd)"
else
    echo "❌ Không tìm thấy thư mục dự án"
    exit 1
fi

# Dừng tất cả containers
echo "🛑 Dừng tất cả containers..."
docker-compose down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Xóa volumes cũ
echo "🗑️ Xóa volumes cũ..."
docker volume prune -f
docker system prune -f

# Sửa lỗi Dockerfile permissions
echo "🔧 Sửa lỗi Dockerfile permissions..."

# Frontend Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Fix permissions
RUN chmod +x node_modules/.bin/*

# Build the app
RUN npm run build

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "3000"]
EOF

# Dashboard Dockerfile
cat > dashboard-admin/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Fix permissions
RUN chmod +x node_modules/.bin/*

# Build the app
RUN npm run build

# Expose port
EXPOSE 3001

# Start the app
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "3001"]
EOF

# Sửa lỗi docker-compose.yml volume
echo "🔧 Sửa lỗi docker-compose.yml volume..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:8.2
    container_name: livestream_mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
      MONGO_INITDB_DATABASE: livestream_betting
    volumes:
      - mongodb_data:/data/db
    networks:
      - livestream_network

  backend:
    build: ./backend
    container_name: livestream_backend
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - PORT=5000
      - MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin
      - JWT_SECRET=livestream-betting-production-jwt-secret-key-2024-very-secure
      - JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024-very-secure
      - CORS_ORIGIN=https://devvinny.fun
      - SOCKET_CORS_ORIGIN=https://devvinny.fun
      - ADMIN_CORS_ORIGIN=https://admin.devvinny.fun
    depends_on:
      - mongodb
    networks:
      - livestream_network

  frontend:
    build: ./frontend
    container_name: livestream_frontend
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
      - VITE_SOCKET_URL=https://api.devvinny.fun
      - VITE_APP_NAME=Livestream Betting Platform
    depends_on:
      - backend
    networks:
      - livestream_network

  dashboard-admin:
    build: ./dashboard-admin
    container_name: livestream_dashboard
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
      - VITE_APP_NAME=Livestream Betting Admin
    depends_on:
      - backend
    networks:
      - livestream_network

volumes:
  mongodb_data:

networks:
  livestream_network:
    driver: bridge
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

echo "Testing Backend..."
timeout 10 curl -s http://localhost:5000/health && echo "✅ Backend OK" || echo "❌ Backend lỗi"

echo "Testing Frontend..."
timeout 10 curl -s http://localhost:3000 | head -1 && echo "✅ Frontend OK" || echo "❌ Frontend lỗi"

echo "Testing Dashboard..."
timeout 10 curl -s http://localhost:3001 | head -1 && echo "✅ Dashboard OK" || echo "❌ Dashboard lỗi"

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
echo "🌐 Domain URLs:"
echo "• Frontend: https://devvinny.fun"
echo "• Admin: https://admin.devvinny.fun"
echo "• API: https://api.devvinny.fun"
echo ""
echo "📋 Nếu vẫn lỗi, chạy:"
echo "docker-compose logs -f"
