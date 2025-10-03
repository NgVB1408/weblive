@echo off
echo ==========================================
echo LIVESTREAM BETTING PLATFORM - SETUP
echo ==========================================

echo.
echo [1/6] Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed or not running
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✅ Docker is installed

echo.
echo [2/6] Checking Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not available
    echo Please ensure Docker Desktop is running
    pause
    exit /b 1
)
echo ✅ Docker Compose is available

echo.
echo [3/6] Creating environment file...
if not exist .env (
    copy env.example .env
    echo ✅ Environment file created from template
) else (
    echo ℹ️  Environment file already exists
)

echo.
echo [4/6] Building Docker images...
docker-compose build --no-cache

echo.
echo [5/6] Starting services...
docker-compose up -d

echo.
echo [6/6] Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo ==========================================
echo 🎉 SETUP COMPLETED SUCCESSFULLY!
echo ==========================================
echo.
echo Services are running on:
echo - Frontend: http://localhost:3000
echo - Admin Dashboard: http://localhost:3001
echo - Backend API: http://localhost:5000
echo - MongoDB: localhost:27017
echo.
echo Default Admin Credentials:
echo - Email: admin@livestream.com
echo - Password: admin123
echo.
echo To view logs: docker-compose logs -f
echo To stop services: docker-compose down
echo.
pause
