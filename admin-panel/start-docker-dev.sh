#!/bin/bash

echo "🚀 Starting AFRO Admin Panel with Docker Hot Reload..."

# Stop any existing container
docker-compose -f docker-compose.dev.yml down

# Build and start the container
docker-compose -f docker-compose.dev.yml up --build

echo "✅ Admin Panel is running at http://localhost:3002"
echo "🔄 Hot reload is enabled - changes will be applied automatically"
echo "📝 Logs are shown above. Press Ctrl+C to stop"
