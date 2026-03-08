# Docker Setup Guide - Complete Development Environment

## Overview

This guide will help you set up the entire AFRO Barber Shop system using Docker, providing a consistent development environment across all platforms.

---

## Why Use Docker?

### ✅ Benefits

1. **Consistency**: Same environment on all machines (Windows, macOS, Linux)
2. **Easy Setup**: One command to start everything
3. **Isolation**: No conflicts with other projects
4. **Clean**: Easy to reset and start fresh
5. **Production-Ready**: Same setup for dev and production
6. **Team Collaboration**: Everyone uses identical environment

### ❌ Without Docker Issues

- "Works on my machine" problems
- Complex PostgreSQL installation
- Version conflicts
- Manual configuration
- Time-consuming setup

---

## Prerequisites

### 1. Install Docker Desktop

#### Windows
1. Download: https://www.docker.com/products/docker-desktop/
2. Run installer
3. Restart computer
4. Verify: `docker --version`

#### macOS
1. Download: https://www.docker.com/products/docker-desktop/
2. Drag to Applications
3. Open Docker Desktop
4. Verify: `docker --version`

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker-compose --version
```

### 2. Verify Installation

```bash
# Check Docker
docker --version
# Expected: Docker version 20.x.x or higher

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.x.x or higher

# Test Docker
docker run hello-world
# Should download and run successfully
```

---

## Project Structure

```
afro-barber-shop/
├── docker-compose.yml          # Main orchestration file
├── backend/
│   ├── Dockerfile             # Backend container config
│   ├── .dockerignore          # Files to exclude
│   ├── .env                   # Environment variables
│   └── src/                   # Backend source code
├── admin-panel/
│   ├── Dockerfile             # Admin panel container config
│   ├── .dockerignore          # Files to exclude
│   └── src/                   # Admin panel source code
└── DOCKER_SETUP_GUIDE.md      # This file
```

---

## Quick Start (3 Steps)

### Step 1: Configure Environment

Create `backend/.env` file:

```env
NODE_ENV=development
PORT=3001

# Database (Docker service name)
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres_password
DB_NAME=afro_db

# Firebase (Add your credentials)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-email@project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Key\n-----END PRIVATE KEY-----\n"
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com

# JWT
JWT_SECRET=your-jwt-secret-key-here
JWT_EXPIRATION=7d
```

Create `admin-panel/.env.local` file:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
```

### Step 2: Start All Services

```bash
# From project root directory
docker-compose up -d
```

This single command will:
- ✅ Download PostgreSQL image
- ✅ Create database container
- ✅ Build backend container
- ✅ Build admin panel container
- ✅ Start pgAdmin (database UI)
- ✅ Create network between services
- ✅ Set up volumes for data persistence

### Step 3: Verify Everything is Running

```bash
# Check running containers
docker-compose ps

# Expected output:
# NAME                  STATUS    PORTS
# afro_postgres         Up        0.0.0.0:5432->5432/tcp
# afro_backend          Up        0.0.0.0:3001->3001/tcp
# afro_admin_panel      Up        0.0.0.0:3002->3000/tcp
# afro_pgadmin          Up        0.0.0.0:5050->80/tcp
```

---

## Access Your Services

### 1. Backend API
- **URL**: http://localhost:3001
- **API Docs**: http://localhost:3001/api/docs
- **Health Check**: http://localhost:3001/health

### 2. Admin Panel
- **URL**: http://localhost:3002
- **Login**: Use Firebase credentials

### 3. PostgreSQL Database
- **Host**: localhost
- **Port**: 5432
- **Username**: postgres
- **Password**: postgres_password
- **Database**: afro_db

### 4. pgAdmin (Database UI)
- **URL**: http://localhost:5050
- **Email**: admin@afro.com
- **Password**: admin

#### Connect to Database in pgAdmin:
1. Open http://localhost:5050
2. Login with credentials above
3. Right-click "Servers" → "Register" → "Server"
4. General tab:
   - Name: AFRO Database
5. Connection tab:
   - Host: postgres
   - Port: 5432
   - Username: postgres
   - Password: postgres_password
6. Click "Save"

---

## Docker Commands Cheat Sheet

### Starting & Stopping

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d backend

# Stop all services
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v

# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Viewing Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs backend
docker-compose logs postgres

# Follow logs (real-time)
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Building & Rebuilding

```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build backend

# Rebuild and start
docker-compose up -d --build

# Force rebuild (no cache)
docker-compose build --no-cache
```

### Executing Commands

```bash
# Execute command in running container
docker-compose exec backend npm run migration:run

# Open shell in container
docker-compose exec backend sh
docker-compose exec postgres psql -U postgres -d afro_db

# Run one-off command
docker-compose run backend npm install new-package
```

### Monitoring

```bash
# View running containers
docker-compose ps

# View resource usage
docker stats

# View container details
docker inspect afro_backend

# View networks
docker network ls

# View volumes
docker volume ls
```

---

## Common Tasks

### 1. Install New NPM Package

```bash
# Backend
docker-compose exec backend npm install package-name

# Admin Panel
docker-compose exec admin-panel npm install package-name

# Then rebuild
docker-compose up -d --build
```

### 2. Run Database Migrations

```bash
# Generate migration
docker-compose exec backend npm run migration:generate -- src/migrations/MigrationName

# Run migrations
docker-compose exec backend npm run migration:run

# Revert migration
docker-compose exec backend npm run migration:revert
```

### 3. Access Database

```bash
# Using psql
docker-compose exec postgres psql -U postgres -d afro_db

# List tables
\dt

# Query data
SELECT * FROM users;

# Exit
\q
```

### 4. View Backend Logs

```bash
# Real-time logs
docker-compose logs -f backend

# Search logs
docker-compose logs backend | grep "error"
```

### 5. Reset Everything

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up -d --build
```

### 6. Backup Database

```bash
# Create backup
docker-compose exec postgres pg_dump -U postgres afro_db > backup.sql

# Restore backup
docker-compose exec -T postgres psql -U postgres afro_db < backup.sql
```

---

## Development Workflow

### Daily Workflow

```bash
# Morning: Start services
docker-compose up -d

# Check everything is running
docker-compose ps

# View logs if needed
docker-compose logs -f backend

# Evening: Stop services
docker-compose down
```

### Making Code Changes

1. **Edit code** in your IDE (changes are live-reloaded)
2. **Backend changes**: Automatically restart (nodemon)
3. **Admin panel changes**: Automatically refresh (Next.js hot reload)
4. **No need to rebuild** unless you change dependencies

### Adding Dependencies

```bash
# Add package
docker-compose exec backend npm install new-package

# Rebuild container
docker-compose up -d --build backend
```

---

## Troubleshooting

### Issue 1: Port Already in Use

**Error:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Find process using port
# Windows
netstat -ano | findstr :3001

# macOS/Linux
lsof -i :3001

# Kill process or change port in docker-compose.yml
```

### Issue 2: Container Won't Start

**Solution:**
```bash
# View logs
docker-compose logs backend

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Issue 3: Database Connection Failed

**Solution:**
```bash
# Check if postgres is healthy
docker-compose ps

# Restart postgres
docker-compose restart postgres

# Check logs
docker-compose logs postgres

# Verify environment variables
docker-compose exec backend env | grep DB_
```

### Issue 4: Changes Not Reflecting

**Solution:**
```bash
# For dependency changes
docker-compose up -d --build

# For code changes (should auto-reload)
docker-compose restart backend

# Clear volumes and rebuild
docker-compose down -v
docker-compose up -d --build
```

### Issue 5: Out of Disk Space

**Solution:**
```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes
```

---

## Production Deployment

### Option 1: Docker Compose (Simple)

```bash
# Create production docker-compose.prod.yml
# Update environment to production
# Deploy to server
docker-compose -f docker-compose.prod.yml up -d
```

### Option 2: Kubernetes (Advanced)

```bash
# Convert to Kubernetes
kompose convert

# Deploy to cluster
kubectl apply -f .
```

### Option 3: Cloud Services

#### AWS ECS
- Push images to ECR
- Create ECS task definitions
- Deploy to ECS cluster

#### Google Cloud Run
- Push images to GCR
- Deploy to Cloud Run
- Auto-scaling enabled

#### Azure Container Instances
- Push images to ACR
- Deploy to ACI
- Managed containers

---

## Environment Variables

### Backend (.env)

```env
# Required
NODE_ENV=development
PORT=3001
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres_password
DB_NAME=afro_db

# Firebase (Required)
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
FIREBASE_DATABASE_URL=

# JWT (Required)
JWT_SECRET=
JWT_EXPIRATION=7d

# Optional
THROTTLE_TTL=60000
THROTTLE_LIMIT=100
CACHE_TTL=300
CACHE_MAX=100
```

### Admin Panel (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

---

## Performance Optimization

### 1. Use Multi-Stage Builds

```dockerfile
# Production Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/main.js"]
```

### 2. Optimize Images

```bash
# Use alpine images (smaller)
FROM node:18-alpine

# Clean up in same layer
RUN npm install && npm cache clean --force
```

### 3. Use .dockerignore

```
node_modules
npm-debug.log
.git
.env
dist
```

---

## Security Best Practices

### 1. Don't Commit Secrets

```bash
# Add to .gitignore
.env
.env.local
docker-compose.override.yml
```

### 2. Use Docker Secrets (Production)

```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  backend:
    secrets:
      - db_password
```

### 3. Run as Non-Root User

```dockerfile
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs
```

### 4. Scan Images for Vulnerabilities

```bash
docker scan afro_backend
```

---

## Monitoring & Logging

### 1. View All Logs

```bash
docker-compose logs -f
```

### 2. Export Logs

```bash
docker-compose logs > logs.txt
```

### 3. Monitor Resources

```bash
docker stats
```

### 4. Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

---

## Comparison: Docker vs Manual Setup

| Feature | Docker | Manual Setup |
|---------|--------|--------------|
| **Setup Time** | 5 minutes | 30-60 minutes |
| **Consistency** | ✅ Same everywhere | ❌ Varies by machine |
| **PostgreSQL** | ✅ Auto-installed | ❌ Manual install |
| **Dependencies** | ✅ Isolated | ❌ Global conflicts |
| **Team Onboarding** | ✅ One command | ❌ Complex docs |
| **Clean Uninstall** | ✅ `docker-compose down` | ❌ Manual cleanup |
| **Production Parity** | ✅ Identical | ❌ Different |
| **Backup/Restore** | ✅ Easy | ❌ Complex |

---

## Conclusion

Using Docker provides:

✅ **Fast Setup**: One command to start everything
✅ **Consistency**: Same environment everywhere
✅ **Isolation**: No conflicts with other projects
✅ **Easy Reset**: Fresh start anytime
✅ **Production Ready**: Deploy with confidence
✅ **Team Friendly**: Everyone uses same setup
✅ **Database Included**: PostgreSQL + pgAdmin
✅ **Auto-Restart**: Services restart on failure

**Recommended**: Use Docker for development and production!

---

## Quick Reference

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View logs
docker-compose logs -f backend

# Rebuild
docker-compose up -d --build

# Fresh start
docker-compose down -v && docker-compose up -d --build

# Access database
docker-compose exec postgres psql -U postgres -d afro_db

# Run migrations
docker-compose exec backend npm run migration:run
```

---

**Last Updated**: March 8, 2026
**Version**: 1.0.0
**Status**: Production Ready ✅
