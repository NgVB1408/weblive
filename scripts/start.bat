@echo off
echo ==========================================
echo STARTING LIVESTREAM BETTING PLATFORM
echo ==========================================

echo Starting all services...
docker-compose up -d

echo.
echo Services started! Access the platform at:
echo - Frontend: http://localhost:3000
echo - Admin Dashboard: http://localhost:3001
echo - Backend API: http://localhost:5000
echo.
echo To view logs: docker-compose logs -f
echo To stop services: docker-compose down
echo.
pause
