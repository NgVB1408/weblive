@echo off
echo ==========================================
echo QUICK START - LIVESTREAM BETTING PLATFORM
echo ==========================================

echo.
echo [1/4] Stopping any running containers...
docker-compose down >nul 2>&1

echo.
echo [2/4] Pulling MongoDB image...
docker pull mongo:7.0

echo.
echo [3/4] Starting only MongoDB first...
docker-compose up -d mongodb

echo.
echo [4/4] Waiting for MongoDB to be ready...
timeout /t 10 /nobreak >nul

echo.
echo ==========================================
echo 🎉 MONGODB IS READY!
echo ==========================================
echo.
echo MongoDB is running on: localhost:27017
echo Database: livestream_betting
echo Username: admin
echo Password: password123
echo.
echo Now you can:
echo 1. Run: docker-compose up -d backend
echo 2. Run: docker-compose up -d frontend
echo 3. Run: docker-compose up -d dashboard
echo.
echo Or run all at once: docker-compose up -d
echo.
pause
