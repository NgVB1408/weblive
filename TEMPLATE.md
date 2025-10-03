# 📌 DỰ ÁN CLONE WEBSITE LIVESTREAM + DASHBOARD QUẢN LÝ

## 🎯 Mục tiêu

Xây dựng hệ thống website livestream + đặt cược tương tự
[dv6666.net](https://dv6666.net/), nhưng hoàn toàn thuộc quyền quản lý
của chúng ta.

------------------------------------------------------------------------

## 📂 Cấu trúc thư mục

    project-root/
    ├── frontend/                # Vue 3 + TailwindCSS (UI cho user)
    │   ├── public/              # Static assets (logo, hình ảnh)
    │   ├── src/
    │   │   ├── assets/          # Icon, ảnh nền
    │   │   ├── components/      # UI Components (Navbar, LivestreamPlayer, BetButton)
    │   │   ├── layouts/         # Template layout
    │   │   ├── pages/           # Trang chính (Home, Livestream, Profile, Login)
    │   │   ├── router/          # Vue Router
    │   │   ├── store/           # Pinia / Vuex (state management)
    │   │   └── utils/           # Hàm tiện ích
    │   ├── .env.example         # Config môi trường
    │   └── vite.config.js
    │
    ├── backend/                 # Node.js (Express.js API)
    │   ├── src/
    │   │   ├── routes/          # Xử lý API routes (auth, bets, users, payment)
    │   │   ├── controllers/     # Xử lý logic chính
    │   │   ├── models/          # MongoDB schema (User, BetHistory, Wallet)
    │   │   ├── middleware/      # Auth middleware
    │   │   └── utils/           # JWT, helper functions
    │   ├── .env.example         # Config môi trường backend
    │   └── server.js
    │
    ├── database/                # MongoDB config
    │   └── init.js
    │
    ├── dashboard-admin/         # Dashboard quản trị (Vue + Tailwind)
    │   ├── pages/               # User management, API monitoring, Transactions
    │   └── components/          # Chart, Table
    │
    ├── docs/                    # Tài liệu
    │   └── TEMPLATE.md          # Checklist và hướng dẫn
    │
    └── docker-compose.yml       # Chạy toàn hệ thống

------------------------------------------------------------------------

## ⚙️ File `.env` mẫu

### Frontend `.env`

``` env
VITE_API_BASE_URL=http://localhost:5000/api
VITE_LIVESTREAM_URL=https://public-livestream-source.com/stream
```

### Backend `.env`

``` env
PORT=5000
MONGO_URI=mongodb://localhost:27017/livestream_bet
JWT_SECRET=supersecretkey
API_KEY_PROVIDER=your_api_key_here
```

------------------------------------------------------------------------

## 🔌 Ví dụ API Call (Frontend → Backend)

``` js
// Gửi yêu cầu đặt cược
import axios from "axios";

const placeBet = async (token, matchId, amount) => {
  const res = await axios.post(
    `${import.meta.env.VITE_API_BASE_URL}/bets/place`,
    { matchId, amount },
    {
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  return res.data;
};
```

------------------------------------------------------------------------

## ✅ Checklist cho DEV

-   [ ] UI (Vue + Tailwind)\
-   [ ] Livestream Player (HLS / M3U8)\
-   [ ] API Auth (JWT)\
-   [ ] Đăng ký / Đăng nhập\
-   [ ] Quản lý người dùng\
-   [ ] Quản lý cược\
-   [ ] Tích hợp nạp / rút tiền (API Provider)\
-   [ ] Dashboard Admin (User list, Transaction history, API log)\
-   [ ] Database (MongoDB)\
-   [ ] Docker Compose setup\
-   [ ] Test trên Desktop + Mobile\
-   [ ] Deploy lên VPS/Server

------------------------------------------------------------------------

## 🔗 GitHub Template Gợi ý

-   Vue + Tailwind Starter: <https://github.com/vuejs/vite>\
-   Vue Dashboard Template:
    <https://github.com/justboil/admin-one-vue-tailwind>\
-   Node.js + MongoDB Starter: <https://github.com/expressjs/express>\
-   Fullstack Boilerplate: <https://github.com/async-labs/saas>

------------------------------------------------------------------------

## 🚀 Tiến độ triển khai

1.  Thiết lập **Frontend (Vue + Tailwind)**\
2.  Thiết lập **Backend (Express + MongoDB)**\
3.  Kết nối API Livestream công khai\
4.  Xây dựng chức năng Đăng nhập / Đăng ký\
5.  Xây dựng tính năng Đặt cược & Quản lý tiền\
6.  Xây dựng Dashboard quản trị\
7.  Test toàn bộ hệ thống (Mobile + Desktop)\
8.  Deploy hệ thống hoàn chỉnh
