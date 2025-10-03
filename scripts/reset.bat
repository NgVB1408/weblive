@echo off
echo ==========================================
echo RESETTING LIVESTREAM BETTING PLATFORM
echo ==========================================

echo This will remove all containers, volumes, and data!
echo Are you sure? (Y/N)
set /p confirm=

if /i "%confirm%"=="Y" (
    echo Stopping and removing all services...
    docker-compose down -v --remove-orphans
    
    echo Removing all images...
    docker-compose down --rmi all
    
    echo Cleaning up Docker system...
    docker system prune -f
    
    echo.
    echo ✅ Platform reset completed!
    echo Run setup.bat to start fresh.
) else (
    echo Operation cancelled.
)

echo.
pause
