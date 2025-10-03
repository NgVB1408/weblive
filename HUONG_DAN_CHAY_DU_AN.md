# 🎯 HƯỚNG DẪN CHẠY DỰ ÁN LIVESTREAM BETTING PLATFORM

## 📋 Yêu cầu hệ thống

### Phần mềm cần thiết:
- **Docker Desktop** (Windows/Mac/Linux)
- **Docker Compose** (đi kèm với Docker Desktop)
- **Git** (để clone dự án)
- **MongoDB 8.2** (chạy trong Docker)

### Cấu hình tối thiểu:
- RAM: 4GB trở lên
- CPU: 2 cores trở lên
- Dung lượng ổ cứng: 2GB trống

## 🚀 CÁCH 1: Chạy tự động (Khuyến nghị)

### Bước 1: Cài đặt Docker Desktop
1. Tải Docker Desktop từ: https://www.docker.com/products/docker-desktop
2. Cài đặt và khởi động Docker Desktop
3. Đảm bảo Docker đang chạy (icon Docker xuất hiện ở system tray)

### Bước 2: Clone dự án
```bash
git clone <repository-url>
cd weblive
```

### Bước 3: Chạy setup tự động

**Trên Windows:**
```cmd
scripts\setup.bat
```

**Trên Mac/Linux:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Bước 4: Truy cập ứng dụng
- **Frontend (Người dùng):** http://localhost:3000
- **Admin Dashboard:** http://localhost:3001
- **Backend API:** http://localhost:5000
- **MongoDB:** localhost:27017

## 🔧 CÁCH 2: Chạy thủ công

### Bước 1: Tạo file môi trường
```bash
copy env.example .env
```

### Bước 2: Build và chạy services
```bash
# Build tất cả images
docker-compose build

# Chạy tất cả services
docker-compose up -d
```

### Bước 3: Kiểm tra trạng thái
```bash
# Xem logs
docker-compose logs -f

# Kiểm tra containers
docker-compose ps
```

## 📊 Cấu trúc dự án

```
weblive/
├── backend/                 # API Backend (Node.js + Express)
│   ├── models/             # MongoDB Models
│   ├── routes/             # API Routes
│   ├── socket/             # WebSocket Handlers
│   └── middleware/         # Middleware Functions
├── frontend/               # Frontend (Vue.js 3)
│   ├── src/
│   │   ├── components/     # Vue Components
│   │   ├── pages/          # Page Components
│   │   ├── stores/         # Pinia Stores
│   │   └── router/         # Vue Router
├── dashboard-admin/        # Admin Dashboard (Vue.js 3)
├── database/              # Database initialization
├── nginx/                 # Nginx configuration
├── scripts/               # Utility scripts
└── docker-compose.yml     # Docker services configuration
```

## 🗄️ Cơ sở dữ liệu MongoDB 8.2

### Thông tin kết nối:
- **Host:** localhost:27017
- **Database:** livestream_betting
- **Username:** admin
- **Password:** password123

### Tài khoản mặc định:
- **Email:** admin@livestream.com
- **Password:** admin123
- **Role:** admin

## 🛠️ Quản lý dự án

### Scripts tiện ích:

**Khởi động dự án:**
```bash
# Windows
scripts\start.bat

# Mac/Linux
./scripts/start.sh
```

**Dừng dự án:**
```bash
# Windows
scripts\stop.bat

# Mac/Linux
./scripts/stop.sh
```

**Reset hoàn toàn:**
```bash
# Windows
scripts\reset.bat

# Mac/Linux
./scripts/reset.sh
```

### Docker Commands hữu ích:

```bash
# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của service cụ thể
docker-compose logs -f backend

# Restart service
docker-compose restart backend

# Rebuild và restart
docker-compose up -d --build

# Dừng tất cả services
docker-compose down

# Dừng và xóa volumes (mất dữ liệu)
docker-compose down -v
```

## 🔧 Cấu hình môi trường

### File `.env` chính:
```env
# Database
MONGODB_URI=mongodb://admin:password123@localhost:27017/livestream_betting?authSource=admin

# Server
NODE_ENV=development
PORT=5000

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production

# CORS
CORS_ORIGIN=http://localhost:3000
SOCKET_CORS_ORIGIN=http://localhost:3000
```

## 🌐 Ports và Services

| Service | Port | URL | Mô tả |
|---------|------|-----|-------|
| Frontend | 3000 | http://localhost:3000 | Giao diện người dùng |
| Admin Dashboard | 3001 | http://localhost:3001 | Giao diện quản trị |
| Backend API | 5000 | http://localhost:5000 | API Backend |
| MongoDB | 27017 | localhost:27017 | Database |
| Nginx | 80 | http://localhost | Reverse Proxy |

## 🐛 Troubleshooting

### Lỗi thường gặp:

**1. Docker không chạy:**
```
❌ Error: Cannot connect to the Docker daemon
```
**Giải pháp:** Khởi động Docker Desktop

**2. Port đã được sử dụng:**
```
❌ Error: Port 3000 is already in use
```
**Giải pháp:** 
```bash
# Tìm process sử dụng port
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F
```

**3. MongoDB connection failed:**
```
❌ Error: MongoDB connection failed
```
**Giải pháp:**
```bash
# Restart MongoDB container
docker-compose restart mongodb

# Kiểm tra logs
docker-compose logs mongodb
```

**4. Build failed:**
```
❌ Error: Build failed
```
**Giải pháp:**
```bash
# Clean build
docker-compose build --no-cache

# Xóa images cũ
docker system prune -f
```

## 📱 Tính năng chính

### Frontend (Người dùng):
- ✅ Đăng ký/Đăng nhập
- ✅ Xem trực tiếp (Livestream)
- ✅ Đặt cược trực tiếp
- ✅ Lịch sử cược
- ✅ Ví điện tử
- ✅ Chat trực tiếp

### Admin Dashboard:
- ✅ Quản lý trận đấu
- ✅ Quản lý người dùng
- ✅ Thống kê doanh thu
- ✅ Quản lý cược
- ✅ Cài đặt hệ thống

### Backend API:
- ✅ RESTful API
- ✅ WebSocket (Real-time)
- ✅ Authentication (JWT)
- ✅ Rate Limiting
- ✅ Security Headers

## 🔒 Bảo mật

### Các biện pháp bảo mật:
- ✅ JWT Authentication
- ✅ Password Hashing (bcrypt)
- ✅ CORS Protection
- ✅ Rate Limiting
- ✅ Helmet Security Headers
- ✅ Input Validation
- ✅ SQL Injection Protection

## 📈 Monitoring

### Xem logs:
```bash
# Tất cả services
docker-compose logs -f

# Service cụ thể
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Health Check:
- Backend: http://localhost:5000/health
- Frontend: http://localhost:3000
- Admin: http://localhost:3001

## 🚀 Production Deployment

### Cấu hình Production:
1. Thay đổi `NODE_ENV=production`
2. Cập nhật `JWT_SECRET` mạnh hơn
3. Cấu hình SSL/HTTPS
4. Sử dụng MongoDB Atlas
5. Cấu hình Nginx reverse proxy
6. Setup monitoring và logging

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Docker Desktop đang chạy
2. Ports không bị conflict
3. File `.env` đã được tạo
4. Logs để xem lỗi cụ thể

**Liên hệ:** [Your Contact Info]

---
*Tài liệu này được tạo tự động bởi hệ thống setup của dự án Livestream Betting Platform*
