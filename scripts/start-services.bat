@echo off
echo ==========================================
echo STARTING ALL SERVICES
echo ==========================================

echo Starting MongoDB...
docker-compose up -d mongodb

echo Waiting for MongoDB...
timeout /t 5 /nobreak >nul

echo Starting Backend...
docker-compose up -d backend

echo Waiting for Backend...
timeout /t 10 /nobreak >nul

echo Starting Frontend...
docker-compose up -d frontend

echo Starting Dashboard...
docker-compose up -d dashboard

echo.
echo ==========================================
echo 🎉 ALL SERVICES STARTED!
echo ==========================================
echo.
echo Services are running on:
echo - Frontend: http://localhost:3000
echo - Admin Dashboard: http://localhost:3001
echo - Backend API: http://localhost:5000
echo - MongoDB: localhost:27017
echo.
echo To view logs: docker-compose logs -f
echo.
pause
