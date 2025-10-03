#!/bin/bash

echo "=========================================="
echo "LIVESTREAM BETTING PLATFORM - SETUP"
echo "=========================================="

echo ""
echo "[1/6] Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker is installed"

echo ""
echo "[2/6] Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not available"
    echo "Please install Docker Compose"
    exit 1
fi
echo "✅ Docker Compose is available"

echo ""
echo "[3/6] Creating environment file..."
if [ ! -f .env ]; then
    cp env.example .env
    echo "✅ Environment file created from template"
else
    echo "ℹ️  Environment file already exists"
fi

echo ""
echo "[4/6] Building Docker images..."
docker-compose build --no-cache

echo ""
echo "[5/6] Starting services..."
docker-compose up -d

echo ""
echo "[6/6] Waiting for services to be ready..."
sleep 30

echo ""
echo "=========================================="
echo "🎉 SETUP COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "Services are running on:"
echo "- Frontend: http://localhost:3000"
echo "- Admin Dashboard: http://localhost:3001"
echo "- Backend API: http://localhost:5000"
echo "- MongoDB: localhost:27017"
echo ""
echo "Default Admin Credentials:"
echo "- Email: admin@livestream.com"
echo "- Password: admin123"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop services: docker-compose down"
echo ""
