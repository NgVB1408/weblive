# 🎯 HƯỚNG DẪN CÀI ĐẶT CHI TIẾT - LIVESTREAM BETTING PLATFORM

## 📋 **TỔNG QUAN DỰ ÁN**

Dự án **Livestream Betting Platform** - Clone website dv6666.net với đầy đủ tính năng:
- 🎥 **Livestream Video** với HLS streaming
- 💰 **Live Betting** đặt cược real-time
- 💬 **Live Chat** chat trực tiếp
- 💳 **Payment System** nạp/rút tiền
- 📊 **Admin Dashboard** quản lý hệ thống

---

## 🛠️ **PHẦN 1: CÀI ĐẶT PHẦN MỀM CẦN THIẾT**

### **1.1 Cài đặt Node.js (BẮT BUỘC)**

#### **Windows:**
1. Truy cập: https://nodejs.org/en/download/
2. Tải **LTS version** (khuyến nghị)
3. Chạy file `.msi` đã tải
4. Chọn "Add to PATH" trong quá trình cài đặt
5. Kiểm tra cài đặt:
```bash
node --version
npm --version
```

#### **macOS:**
```bash
# Sử dụng Homebrew (khuyến nghị)
brew install node

# Hoặc tải từ: https://nodejs.org/en/download/
```

#### **Linux (Ubuntu/Debian):**
```bash
# Cập nhật package list
sudo apt update

# Cài đặt Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Kiểm tra
node --version
npm --version
```

### **1.2 Cài đặt MongoDB (BẮT BUỘC)**

#### **Option A: MongoDB Local (Khuyến nghị cho Development)**

**Windows:**
1. Truy cập: https://www.mongodb.com/try/download/community
2. Chọn **Windows** → **MSI** → **Download**
3. Chạy file `.msi` và cài đặt
4. Chọn "Complete" installation
5. Cài đặt **MongoDB Compass** (GUI tool)
6. Khởi động MongoDB service:
```bash
# Kiểm tra service
net start MongoDB

# Hoặc khởi động thủ công
mongod
```

**macOS:**
```bash
# Sử dụng Homebrew
brew tap mongodb/brew
brew install mongodb-community

# Khởi động MongoDB
brew services start mongodb/brew/mongodb-community
```

**Linux (Ubuntu/Debian):**
```bash
# Import public key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Tạo list file
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Cập nhật package list
sudo apt-get update

# Cài đặt MongoDB
sudo apt-get install -y mongodb-org

# Khởi động MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### **Option B: MongoDB Atlas (Cloud - Dễ dàng hơn)**

1. Truy cập: https://www.mongodb.com/atlas
2. Tạo tài khoản miễn phí
3. Tạo **Free Cluster** (M0 Sandbox)
4. Tạo database user
5. Lấy **Connection String**
6. Sử dụng connection string trong file `.env`

### **1.3 Cài đặt Git (KHUYẾN NGHỊ)**

**Windows:**
1. Truy cập: https://git-scm.com/download/win
2. Tải và cài đặt Git for Windows
3. Chọn "Git from the command line and also from 3rd-party software"

**macOS:**
```bash
# Cài đặt Xcode Command Line Tools
xcode-select --install

# Hoặc sử dụng Homebrew
brew install git
```

**Linux:**
```bash
sudo apt update
sudo apt install git
```

### **1.4 Cài đặt Docker (TÙY CHỌN - Cho Production)**

**Windows:**
1. Truy cập: https://www.docker.com/products/docker-desktop/
2. Tải **Docker Desktop for Windows**
3. Cài đặt và khởi động Docker Desktop
4. Kiểm tra: `docker --version`

**macOS:**
1. Truy cập: https://www.docker.com/products/docker-desktop/
2. Tải **Docker Desktop for Mac**
3. Cài đặt và khởi động

**Linux:**
```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Thêm user vào docker group
sudo usermod -aG docker $USER

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

## 📦 **PHẦN 2: TẢI VÀ CÀI ĐẶT DỰ ÁN**

### **2.1 Tải dự án**

#### **Option A: Sử dụng Git (Khuyến nghị)**
```bash
# Clone repository
git clone <repository-url>
cd weblive

# Hoặc nếu chưa có Git, tải ZIP
```

#### **Option B: Tải ZIP**
1. Tải file ZIP của dự án
2. Giải nén vào thư mục `weblive`
3. Mở terminal/command prompt trong thư mục `weblive`

### **2.2 Cài đặt Dependencies**

#### **Backend:**
```bash
cd backend
npm install
```

#### **Frontend:**
```bash
cd frontend
npm install
```

#### **Dashboard Admin:**
```bash
cd dashboard-admin
npm install
```

---

## ⚙️ **PHẦN 3: CẤU HÌNH ENVIRONMENT**

### **3.1 Cấu hình Backend (.env)**

Tạo file `.env` trong thư mục `backend/`:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration
# Option A: MongoDB Local
MONGODB_URI=mongodb://localhost:27017/livestream_betting

# Option B: MongoDB Atlas (thay YOUR_CONNECTION_STRING)
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/livestream_betting

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production
JWT_EXPIRE=15m
JWT_REFRESH_EXPIRE=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Socket.io Configuration
SOCKET_CORS_ORIGIN=http://localhost:3000

# Betting Configuration
MIN_BET_AMOUNT=1000
MAX_BET_AMOUNT=1000000
DEFAULT_CURRENCY=KHR

# Stream Configuration
DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
STREAM_TIMEOUT=30000
```

### **3.2 Cấu hình Frontend (.env)**

Tạo file `.env` trong thư mục `frontend/`:

```env
# API Configuration
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_SOCKET_URL=http://localhost:5000

# Application
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0

# Features
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true

# Default Stream URL (fallback)
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```

### **3.3 Cấu hình Dashboard Admin (.env)**

Tạo file `.env` trong thư mục `dashboard-admin/`:

```env
# API Configuration
VITE_API_BASE_URL=http://localhost:5000/api/v1

# Application
VITE_APP_NAME=Admin Dashboard
VITE_APP_VERSION=1.0.0
```

---

## 🚀 **PHẦN 4: CHẠY DỰ ÁN**

### **4.1 Development Mode (Khuyến nghị)**

#### **Bước 1: Khởi động MongoDB**
```bash
# Windows
net start MongoDB

# macOS
brew services start mongodb/brew/mongodb-community

# Linux
sudo systemctl start mongod
```

#### **Bước 2: Khởi động Backend**
```bash
cd backend
npm run dev
```
**Kết quả:** Backend chạy trên http://localhost:5000

#### **Bước 3: Khởi động Frontend**
```bash
cd frontend
npm run dev
```
**Kết quả:** Website chạy trên http://localhost:3000

#### **Bước 4: Khởi động Dashboard Admin**
```bash
cd dashboard-admin
npm run dev
```
**Kết quả:** Dashboard chạy trên http://localhost:3001

### **4.2 Production Mode (Docker)**

#### **Bước 1: Cài đặt Docker**
- Đảm bảo Docker Desktop đã cài đặt và chạy

#### **Bước 2: Chạy với Docker Compose**
```bash
# Chạy toàn bộ hệ thống
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng hệ thống
docker-compose down
```

#### **Bước 3: Khởi tạo Database**
```bash
# Chạy script khởi tạo database
node database/init.js
```

---

## 🎯 **PHẦN 5: KIỂM TRA CÀI ĐẶT**

### **5.1 Kiểm tra Backend**
1. Truy cập: http://localhost:5000/api/health
2. Kết quả mong đợi:
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 123.456
}
```

### **5.2 Kiểm tra Frontend**
1. Truy cập: http://localhost:3000
2. Kết quả: Website hiển thị với giao diện dark theme

### **5.3 Kiểm tra Dashboard Admin**
1. Truy cập: http://localhost:3001
2. Kết quả: Dashboard admin hiển thị

### **5.4 Kiểm tra Database**
```bash
# Kết nối MongoDB
mongosh

# Hoặc sử dụng MongoDB Compass
# Connection string: mongodb://localhost:27017
```

---

## 🔧 **PHẦN 6: TROUBLESHOOTING**

### **6.1 Lỗi thường gặp**

#### **Lỗi: Port đã được sử dụng**
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:5000 | xargs kill -9
```

#### **Lỗi: MongoDB không kết nối**
```bash
# Kiểm tra MongoDB service
# Windows: Services.msc -> MongoDB
# macOS: brew services list | grep mongodb
# Linux: sudo systemctl status mongod
```

#### **Lỗi: Node modules**
```bash
# Xóa và cài lại
rm -rf node_modules package-lock.json
npm install
```

#### **Lỗi: Socket.io không kết nối**
- Kiểm tra CORS_ORIGIN trong backend/.env
- Kiểm tra VITE_SOCKET_URL trong frontend/.env
- Đảm bảo backend đang chạy trước khi start frontend

### **6.2 Logs và Debug**

#### **Backend Logs:**
```bash
cd backend
npm run dev
# Xem logs trong terminal
```

#### **Frontend Logs:**
```bash
cd frontend
npm run dev
# Xem logs trong terminal
```

#### **Docker Logs:**
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f dashboard
```

---

## 📊 **PHẦN 7: KẾT QUẢ MONG ĐỢI**

Sau khi cài đặt thành công, bạn sẽ có:

### **🎯 Website chính (http://localhost:3000):**
- ✅ Trang chủ với danh sách trận đấu
- ✅ Livestream player với HLS support
- ✅ Live betting system
- ✅ Real-time chat
- ✅ User authentication
- ✅ Wallet management

### **📊 Dashboard Admin (http://localhost:3001):**
- ✅ User management
- ✅ Match management
- ✅ Bet monitoring
- ✅ Analytics và reports
- ✅ System settings

### **🔌 API Backend (http://localhost:5000):**
- ✅ RESTful API endpoints
- ✅ Socket.io real-time communication
- ✅ JWT authentication
- ✅ Database integration

### **💾 Database (MongoDB):**
- ✅ User accounts
- ✅ Match data
- ✅ Bet history
- ✅ Transaction records
- ✅ Real-time updates

---

## 🎉 **HOÀN THÀNH!**

Chúc mừng! Bạn đã cài đặt thành công **Livestream Betting Platform** - Clone dv6666.net với đầy đủ tính năng:

- 🎥 **Livestream Video** với HLS streaming
- 💰 **Live Betting** đặt cược real-time  
- 💬 **Live Chat** chat trực tiếp
- 💳 **Payment System** nạp/rút tiền
- 📊 **Admin Dashboard** quản lý hệ thống

**Truy cập ngay:**
- Website: http://localhost:3000
- Dashboard: http://localhost:3001
- API: http://localhost:5000

---

## 📞 **HỖ TRỢ**

Nếu gặp vấn đề trong quá trình cài đặt:

1. **Kiểm tra logs** trong terminal
2. **Kiểm tra ports** 3000, 3001, 5000, 27017
3. **Kiểm tra MongoDB** đang chạy
4. **Kiểm tra Node.js** phiên bản >= 18.0.0
5. **Kiểm tra file .env** cấu hình đúng

**Chúc bạn sử dụng thành công! 🚀**
