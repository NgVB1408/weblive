#!/bin/bash

# 🔧 SCRIPT SỬA LỖI BUILD FRONTEND VÀ DASHBOARD
# Chạy script này khi gặp lỗi build

echo "🔧 SỬA LỖI BUILD FRONTEND VÀ DASHBOARD"
echo "====================================="

# Kiểm tra và tạo file cấu hình thiếu
echo "📝 Kiểm tra và tạo file cấu hình thiếu..."

# Tạo file .env cho frontend
if [ ! -f "frontend/.env" ]; then
    echo "Tạo file .env cho frontend..."
    cat > frontend/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_SOCKET_URL=https://api.devvinny.fun
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
EOF
fi

# Tạo file .env cho dashboard-admin
if [ ! -f "dashboard-admin/.env" ]; then
    echo "Tạo file .env cho dashboard-admin..."
    cat > dashboard-admin/.env << 'EOF'
VITE_API_BASE_URL=https://api.devvinny.fun/api/v1
VITE_APP_NAME=Livestream Betting Admin
VITE_APP_VERSION=1.0.0
EOF
fi

# Tạo file postcss.config.js cho frontend
if [ ! -f "frontend/postcss.config.js" ]; then
    echo "Tạo postcss.config.js cho frontend..."
    cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF
fi

# Tạo file postcss.config.js cho dashboard-admin
if [ ! -f "dashboard-admin/postcss.config.js" ]; then
    echo "Tạo postcss.config.js cho dashboard-admin..."
    cat > dashboard-admin/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF
fi

# Tạo file tailwind.config.js cho frontend
if [ ! -f "frontend/tailwind.config.js" ]; then
    echo "Tạo tailwind.config.js cho frontend..."
    cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        dark: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        }
      }
    },
  },
  plugins: [],
}
EOF
fi

# Tạo file tailwind.config.js cho dashboard-admin
if [ ! -f "dashboard-admin/tailwind.config.js" ]; then
    echo "Tạo tailwind.config.js cho dashboard-admin..."
    cat > dashboard-admin/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        dark: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        }
      }
    },
  },
  plugins: [],
}
EOF
fi

# Cập nhật vite.config.js cho production
echo "⚙️ Cập nhật vite.config.js cho production..."

# Frontend vite.config.js
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          ui: ['axios', 'socket.io-client', 'sweetalert2']
        }
      }
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
      '/socket.io': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        ws: true,
      },
    },
  },
})
EOF

# Dashboard-admin vite.config.js
cat > dashboard-admin/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          ui: ['axios', 'chart.js', 'vue-chartjs']
        }
      }
    }
  },
  server: {
    port: 3001,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
})
EOF

echo "✅ Đã tạo các file cấu hình thiếu"
echo ""
echo "🔄 Bây giờ thử build lại:"
echo "docker-compose build --no-cache"
echo "docker-compose up -d"
echo ""
echo "📋 Nếu vẫn lỗi, kiểm tra logs:"
echo "docker-compose logs frontend"
echo "docker-compose logs dashboard-admin"
