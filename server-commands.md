# 🚀 HƯỚNG DẪN TRIỂN KHAI TRÊN SERVER

## 📋 Các lệnh cần chạy trên server

### 1. Chạy script tự động hoàn chỉnh:
```bash
# Tải script về server
wget https://raw.githubusercontent.com/NgVB1408/weblive/main/server-deploy.sh

# Chạy script
bash server-deploy.sh
```

### 2. Hoặc chạy script nhanh:
```bash
# Tải script nhanh
wget https://raw.githubusercontent.com/NgVB1408/weblive/main/quick-deploy.sh

# Chạy script nhanh
bash quick-deploy.sh
```

### 3. Hoặc chạy từng bước thủ công:

```bash
# Bước 1: Cài đặt Docker (nếu chưa có)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker

# Bước 2: Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Bước 3: Di chuyển vào thư mục dự án
cd /root/weblive

# Bước 4: Tạo file .env
cat > .env << 'EOF'
MONGODB_URI=mongodb://admin:password123@mongodb:27017/livestream_betting?authSource=admin
NODE_ENV=production
PORT=5000
JWT_SECRET=livestream-betting-production-jwt-secret-key-2024
JWT_REFRESH_SECRET=livestream-betting-production-refresh-secret-key-2024
CORS_ORIGIN=http://160.187.246.155:3000
SOCKET_CORS_ORIGIN=http://160.187.246.155:3000
ADMIN_CORS_ORIGIN=http://160.187.246.155:3001
EOF

# Bước 5: Mở firewall
sudo ufw allow 3000 3001 5000 80 443

# Bước 6: Build và khởi động
docker-compose build
docker-compose up -d

# Bước 7: Kiểm tra trạng thái
docker-compose ps
docker-compose logs -f
```

## 🛠️ Scripts quản lý sau khi triển khai

```bash
# Khởi động tất cả services
./start.sh

# Dừng tất cả services  
./stop.sh

# Khởi động lại services
./restart.sh

# Xem logs real-time
./logs.sh

# Kiểm tra trạng thái
./status.sh
```

## 🌐 URLs sau khi triển khai

- **Frontend (Người dùng):** http://160.187.246.155:3000
- **Admin Dashboard:** http://160.187.246.155:3001
- **Backend API:** http://160.187.246.155:5000

## 🔧 Troubleshooting

```bash
# Xem logs chi tiết
docker-compose logs -f

# Restart service cụ thể
docker-compose restart backend

# Rebuild hoàn toàn
docker-compose down
docker-compose up -d --build

# Kiểm tra dung lượng
df -h

# Kiểm tra RAM
free -h
```
