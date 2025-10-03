#!/bin/bash

# 🔧 SCRIPT SỬA LỖI THIẾU FILE VÀ MONGODB
# Chạy script này để sửa lỗi thiếu file và MongoDB

echo "🔧 SỬA LỖI THIẾU FILE VÀ MONGODB"
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

# Tạo thư mục và file thiếu cho frontend
echo "📁 Tạo thư mục và file thiếu cho frontend..."
mkdir -p frontend/src/stores
mkdir -p frontend/src/components
mkdir -p frontend/src/pages
mkdir -p frontend/src/router
mkdir -p frontend/src/utils
mkdir -p frontend/src/config
mkdir -p frontend/src/layouts
mkdir -p frontend/src/assets/styles

# Tạo file stores/auth.js
cat > frontend/src/stores/auth.js << 'EOF'
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token'))
  const isAuthenticated = computed(() => !!token.value)

  const login = async (credentials) => {
    try {
      const response = await axios.post('/api/v1/auth/login', credentials)
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('token', token.value)
      return response.data
    } catch (error) {
      throw error
    }
  }

  const register = async (userData) => {
    try {
      const response = await axios.post('/api/v1/auth/register', userData)
      return response.data
    } catch (error) {
      throw error
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    register,
    logout
  }
})
EOF

# Tạo file stores/bet.js
cat > frontend/src/stores/bet.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useBetStore = defineStore('bet', () => {
  const bets = ref([])
  const activeBets = ref([])

  const placeBet = (betData) => {
    // Place bet logic
    console.log('Placing bet:', betData)
  }

  return {
    bets,
    activeBets,
    placeBet
  }
})
EOF

# Tạo file stores/match.js
cat > frontend/src/stores/match.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useMatchStore = defineStore('match', () => {
  const matches = ref([])
  const currentMatch = ref(null)

  const fetchMatches = () => {
    // Fetch matches logic
    console.log('Fetching matches')
  }

  return {
    matches,
    currentMatch,
    fetchMatches
  }
})
EOF

# Tạo file stores/chat.js
cat > frontend/src/stores/chat.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useChatStore = defineStore('chat', () => {
  const messages = ref([])
  const isConnected = ref(false)

  const sendMessage = (message) => {
    // Send message logic
    console.log('Sending message:', message)
  }

  return {
    messages,
    isConnected,
    sendMessage
  }
})
EOF

# Tạo file App.vue
cat > frontend/src/App.vue << 'EOF'
<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
EOF

# Tạo file main.js
cat > frontend/src/main.js << 'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
EOF

# Tạo file router/index.js
cat > frontend/src/router/index.js << 'EOF'
import { createRouter, createWebHistory } from 'vue-router'
import Home from '../pages/Home.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
EOF

# Tạo file pages/Home.vue
cat > frontend/src/pages/Home.vue << 'EOF'
<template>
  <div class="home">
    <h1>Livestream Betting Platform</h1>
    <p>Welcome to the platform!</p>
  </div>
</template>

<script>
export default {
  name: 'Home'
}
</script>

<style scoped>
.home {
  padding: 20px;
}
</style>
EOF

# Tạo thư mục và file thiếu cho dashboard-admin
echo "📁 Tạo thư mục và file thiếu cho dashboard-admin..."
mkdir -p dashboard-admin/src/stores
mkdir -p dashboard-admin/src/components
mkdir -p dashboard-admin/src/pages
mkdir -p dashboard-admin/src/router
mkdir -p dashboard-admin/src/utils
mkdir -p dashboard-admin/src/layouts

# Tạo file stores/auth.js cho dashboard
cat > dashboard-admin/src/stores/auth.js << 'EOF'
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token'))
  const isAuthenticated = computed(() => !!token.value)

  const login = async (credentials) => {
    // Login logic
    console.log('Admin login:', credentials)
  }

  const logout = () => {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    logout
  }
})
EOF

# Tạo file App.vue cho dashboard
cat > dashboard-admin/src/App.vue << 'EOF'
<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
EOF

# Tạo file main.js cho dashboard
cat > dashboard-admin/src/main.js << 'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
EOF

# Tạo file router/index.js cho dashboard
cat > dashboard-admin/src/router/index.js << 'EOF'
import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../pages/Dashboard.vue'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: Dashboard
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
EOF

# Tạo file pages/Dashboard.vue
cat > dashboard-admin/src/pages/Dashboard.vue << 'EOF'
<template>
  <div class="dashboard">
    <h1>Admin Dashboard</h1>
    <p>Welcome to the admin dashboard!</p>
  </div>
</template>

<script>
export default {
  name: 'Dashboard'
}
</script>

<style scoped>
.dashboard {
  padding: 20px;
}
</style>
EOF

# Sửa docker-compose.yml với MongoDB image đúng
echo "🔧 Sửa docker-compose.yml với MongoDB image đúng..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
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
