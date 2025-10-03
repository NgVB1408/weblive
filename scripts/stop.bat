@echo off
echo ==========================================
echo STOPPING LIVESTREAM BETTING PLATFORM
echo ==========================================

echo Stopping all services...
docker-compose down

echo.
echo All services stopped!
echo.
pause
