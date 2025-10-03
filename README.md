# 🎯 Livestream Betting Platform - Clone dv6666.net

Một nền tảng cá cược trực tiếp với livestream video, được xây dựng để giống hệt website dv6666.net với đầy đủ tính năng hiện đại.

## 🚀 Tính năng chính (Giống dv6666.net)

### 🎥 **Livestream & Video**
- ✅ **HLS Video Streaming** - Phát video trực tiếp chất lượng cao
- ✅ **Real-time Player** - Video player tùy chỉnh với controls
- ✅ **Multi-stream Support** - Hỗ trợ nhiều luồng video đồng thời
- ✅ **Auto Quality** - Tự động điều chỉnh chất lượng theo băng thông

### 💰 **Betting System**
- ✅ **Live Betting** - Đặt cược trong khi xem trực tiếp
- ✅ **Real-time Odds** - Tỷ lệ cược cập nhật real-time
- ✅ **Multiple Bet Types** - Nhiều loại cược (thắng, thua, hòa, over/under)
- ✅ **Quick Bet** - Đặt cược nhanh với các mức tiền có sẵn
- ✅ **Bet History** - Lịch sử cược chi tiết

### 💬 **Live Chat**
- ✅ **Real-time Chat** - Chat trực tiếp với người xem khác
- ✅ **User Management** - Quản lý người dùng chat
- ✅ **Moderation** - Kiểm duyệt tin nhắn
- ✅ **Emoji Support** - Hỗ trợ emoji và biểu tượng

### 💳 **Payment System**
- ✅ **Multi-currency** - Hỗ trợ nhiều loại tiền tệ (KHR, USD, VND)
- ✅ **Crypto Support** - Hỗ trợ USDT, BTC, ETH
- ✅ **Bank Transfer** - Chuyển khoản ngân hàng
- ✅ **E-wallet** - Ví điện tử (MoMo, ZaloPay)
- ✅ **Instant Deposit** - Nạp tiền tức thì

### 📊 **Admin Dashboard**
- ✅ **User Management** - Quản lý người dùng
- ✅ **Match Management** - Quản lý trận đấu
- ✅ **Bet Monitoring** - Giám sát cược
- ✅ **Analytics** - Thống kê và báo cáo
- ✅ **Settings** - Cấu hình hệ thống

## 🛠️ Công nghệ sử dụng

### **Frontend**
- **Vue 3** - Framework JavaScript hiện đại
- **Tailwind CSS** - Utility-first CSS framework
- **Pinia** - State management
- **Vue Router** - Client-side routing
- **Socket.io Client** - Real-time communication
- **HLS.js** - Video streaming
- **Chart.js** - Data visualization

### **Backend**
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **Socket.io** - Real-time communication
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing

### **Infrastructure**
- **Docker** - Containerization
- **Nginx** - Reverse proxy
- **MongoDB** - Database
- **Redis** - Caching (optional)

## 📁 Cấu trúc dự án

```
weblive/
├── frontend/                 # Vue 3 + TailwindCSS (UI cho user)
│   ├── src/
│   │   ├── components/       # UI Components (Navbar, LivestreamPlayer, BetButton)
│   │   ├── layouts/          # Template layout (MainLayout, AuthLayout)
│   │   ├── pages/            # Trang chính (Home, Livestream, Profile, Login)
│   │   ├── router/           # Vue Router
│   │   ├── stores/           # Pinia (state management)
│   │   ├── config/           # API configuration
│   │   ├── utils/            # Hàm tiện ích
│   │   └── assets/           # Icon, ảnh nền
│   ├── package.json          # Dependencies frontend
│   ├── vite.config.js        # Vite configuration
│   ├── tailwind.config.js    # Tailwind configuration
│   └── Dockerfile            # Docker configuration
│
├── backend/                  # Node.js (Express.js API)
│   ├── models/               # MongoDB schema (User, Match, Bet)
│   ├── routes/               # API routes (auth, bets, users, wallet, admin)
│   ├── middleware/           # Auth middleware, error handling
│   ├── socket/               # Socket.io handlers (match, chat, bet)
│   ├── package.json          # Dependencies backend
│   ├── server.js             # Main server file
│   └── Dockerfile            # Docker configuration
│
├── dashboard-admin/           # Dashboard quản trị (Vue + Tailwind)
│   ├── src/
│   │   ├── pages/            # User management, API monitoring, Transactions
│   │   ├── components/       # Chart, Table
│   │   └── layouts/          # Admin layout
│   ├── package.json          # Dependencies dashboard
│   └── Dockerfile            # Docker configuration
│
├── database/                  # MongoDB config
│   └── init.js               # Database initialization
│
├── nginx/                     # Nginx configuration
│   └── nginx.conf            # Reverse proxy config
│
├── docker-compose.yml        # Chạy toàn hệ thống
├── README.md                 # Tài liệu hướng dẫn
└── TEMPLATE.md               # Checklist và hướng dẫn
```

## 🚀 Cài đặt và chạy

### **Yêu cầu hệ thống**
- Node.js >= 18.0.0
- MongoDB >= 5.0
- Docker & Docker Compose (optional)
- npm hoặc yarn

### **1. Development Mode**

#### **Backend**
```bash
cd backend
npm install
cp .env.example .env
# Chỉnh sửa .env với thông tin của bạn
npm run dev
```

#### **Frontend**
```bash
cd frontend
npm install
cp .env.example .env
# Chỉnh sửa .env với thông tin của bạn
npm run dev
```

#### **Dashboard Admin**
```bash
cd dashboard-admin
npm install
npm run dev
```

### **2. Production Mode (Docker)**

```bash
# Chạy toàn bộ hệ thống
docker-compose up -d

# Khởi tạo database
node database/init.js
```

### **3. Truy cập ứng dụng**
- **Frontend**: http://localhost:3000
- **Dashboard Admin**: http://localhost:3001
- **Backend API**: http://localhost:5000
- **API Health**: http://localhost:5000/api/health

## 🔧 Cấu hình

### **Backend Environment Variables**
```env
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/livestream_betting

# JWT
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret

# CORS
CORS_ORIGIN=http://localhost:3000

# Socket.io
SOCKET_CORS_ORIGIN=http://localhost:3000

# Betting
MIN_BET_AMOUNT=1000
MAX_BET_AMOUNT=1000000
DEFAULT_CURRENCY=KHR
```

### **Frontend Environment Variables**
```env
# API
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_SOCKET_URL=http://localhost:5000

# App
VITE_APP_NAME=Livestream Betting Platform
VITE_APP_VERSION=1.0.0

# Features
VITE_ENABLE_CHAT=true
VITE_ENABLE_NOTIFICATIONS=true

# Stream
VITE_DEFAULT_STREAM_URL=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```

## 📚 API Documentation

### **Authentication**
- `POST /api/v1/auth/register` - Đăng ký tài khoản
- `POST /api/v1/auth/login` - Đăng nhập
- `POST /api/v1/auth/logout` - Đăng xuất
- `POST /api/v1/auth/refresh-token` - Làm mới token
- `GET /api/v1/auth/profile` - Lấy thông tin profile
- `PUT /api/v1/auth/profile` - Cập nhật profile

### **Matches**
- `GET /api/v1/matches` - Lấy danh sách trận đấu
- `GET /api/v1/matches/live` - Lấy trận đấu đang live
- `GET /api/v1/matches/upcoming` - Lấy trận đấu sắp diễn ra
- `GET /api/v1/matches/featured` - Lấy trận đấu nổi bật
- `GET /api/v1/matches/:id` - Lấy chi tiết trận đấu
- `POST /api/v1/matches` - Tạo trận đấu mới (Admin)
- `PUT /api/v1/matches/:id` - Cập nhật trận đấu (Admin)

### **Betting**
- `POST /api/v1/bets/place` - Đặt cược
- `GET /api/v1/bets/active` - Lấy cược đang chờ
- `GET /api/v1/bets/history` - Lịch sử cược
- `GET /api/v1/bets/stats` - Thống kê cược
- `DELETE /api/v1/bets/:id/cancel` - Hủy cược

### **Wallet**
- `GET /api/v1/wallet/balance` - Số dư ví
- `POST /api/v1/wallet/deposit` - Nạp tiền
- `POST /api/v1/wallet/withdraw` - Rút tiền
- `GET /api/v1/wallet/transactions` - Lịch sử giao dịch
- `POST /api/v1/wallet/transfer` - Chuyển tiền

### **Admin**
- `GET /api/v1/admin/dashboard` - Dashboard dữ liệu
- `GET /api/v1/users` - Quản lý người dùng
- `GET /api/v1/admin/transactions` - Lịch sử giao dịch
- `GET /api/v1/admin/logs` - Log hệ thống
- `POST /api/v1/admin/settings` - Cập nhật cài đặt

## 🔌 Socket.io Events

### **Client → Server**
- `join-match` - Tham gia phòng trận đấu
- `leave-match` - Rời phòng trận đấu
- `chat-message` - Gửi tin nhắn chat
- `place-bet` - Đặt cược real-time
- `cancel-bet` - Hủy cược

### **Server → Client**
- `viewer-count-updated` - Cập nhật số người xem
- `odds-updated` - Cập nhật tỷ lệ cược
- `match-updated` - Cập nhật thông tin trận đấu
- `bet-result` - Kết quả cược
- `new-chat-message` - Tin nhắn chat mới
- `user-joined` - Người dùng tham gia
- `user-left` - Người dùng rời đi

## 🎨 UI/UX Features

### **Design System**
- ✅ **Dark Theme** với gradient colors (giống dv6666.net)
- ✅ **Responsive Design** cho mobile/desktop
- ✅ **Real-time Updates** với Socket.io
- ✅ **Toast Notifications** cho user feedback
- ✅ **Loading States** và error handling
- ✅ **Interactive Components** (betting panel, chat)

### **Components**
- ✅ **LivestreamPlayer** - Video player với HLS support
- ✅ **BetButton** - Component đặt cược với quick amounts
- ✅ **MatchCard** - Card hiển thị trận đấu
- ✅ **ChatBox** - Chat real-time với moderation
- ✅ **Navbar** - Navigation với user menu
- ✅ **Footer** - Footer với links và social

## 🔒 Bảo mật

### **Authentication & Authorization**
- ✅ **JWT Tokens** - Access token + Refresh token
- ✅ **Password Hashing** - bcryptjs với salt rounds
- ✅ **Rate Limiting** - Giới hạn số request
- ✅ **CORS Protection** - Cross-origin resource sharing
- ✅ **Input Validation** - Validate tất cả input
- ✅ **SQL Injection Protection** - Mongoose ODM

### **Security Headers**
- ✅ **Helmet.js** - Security headers
- ✅ **XSS Protection** - Cross-site scripting
- ✅ **CSRF Protection** - Cross-site request forgery
- ✅ **Content Security Policy** - CSP headers

## 📱 Mobile Support

### **Responsive Design**
- ✅ **Mobile-first** approach
- ✅ **Touch-friendly** interface
- ✅ **Swipe gestures** support
- ✅ **Mobile betting** optimized
- ✅ **PWA ready** (Progressive Web App)

## 🚀 Performance

### **Optimization**
- ✅ **Lazy Loading** components
- ✅ **Image Optimization** với WebP support
- ✅ **Code Splitting** với dynamic imports
- ✅ **Caching Strategies** với Redis
- ✅ **CDN Ready** cho static assets

### **Monitoring**
- ✅ **Health Checks** endpoints
- ✅ **Error Logging** với Winston
- ✅ **Performance Metrics** với monitoring
- ✅ **Real-time Analytics** với Socket.io

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm run test

# E2E tests
npm run test:e2e
```

## 📈 Deployment

### **Production Checklist**
- ✅ **Environment Variables** configured
- ✅ **Database** initialized
- ✅ **SSL Certificates** installed
- ✅ **Domain** configured
- ✅ **CDN** setup (optional)
- ✅ **Monitoring** configured

### **Docker Deployment**
```bash
# Build and deploy
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose up -d --scale backend=3
```

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

MIT License - xem file LICENSE để biết thêm chi tiết.

## 📞 Support

Nếu có vấn đề, vui lòng tạo issue trên GitHub repository.

---

**⚠️ Lưu ý**: Đây là dự án demo cho mục đích học tập. Không sử dụng cho mục đích thương mại thực tế mà không tuân thủ các quy định pháp luật địa phương.

**🎯 Mục tiêu**: Tạo ra một nền tảng livestream betting hoàn chỉnh, giống hệt dv6666.net với đầy đủ tính năng hiện đại và giao diện đẹp mắt.