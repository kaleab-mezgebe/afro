# Docker Troubleshooting Guide

## Error: Docker Desktop Not Running

### Symptoms
```
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/...": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

### Solution

#### Step 1: Start Docker Desktop

**Windows:**
1. Press `Windows Key`
2. Type "Docker Desktop"
3. Click on "Docker Desktop" application
4. Wait for Docker to start (whale icon in system tray should be steady, not animated)
5. You'll see "Docker Desktop is running" notification

**Alternative:**
- Open Start Menu → Docker → Docker Desktop
- Or double-click Docker Desktop icon on desktop

#### Step 2: Verify Docker is Running

```bash
# Check Docker version
docker --version

# Check Docker is responding
docker ps

# Expected: Empty list or running containers (not an error)
```

#### Step 3: Try Docker Compose Again

```bash
# Navigate to project root
cd D:\customer_app

# Start services
docker-compose up -d
```

---

## Common Docker Desktop Issues on Windows

### Issue 1: Docker Desktop Won't Start

**Symptoms:**
- Docker Desktop icon shows error
- "Docker Desktop starting..." never completes

**Solutions:**

1. **Enable WSL 2** (Recommended)
   ```powershell
   # Run PowerShell as Administrator
   wsl --install
   wsl --set-default-version 2
   
   # Restart computer
   ```

2. **Enable Virtualization in BIOS**
   - Restart computer
   - Enter BIOS (usually F2, F10, or Del key)
   - Enable "Intel VT-x" or "AMD-V"
   - Save and exit

3. **Enable Hyper-V** (Windows Pro/Enterprise)
   ```powershell
   # Run PowerShell as Administrator
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   
   # Restart computer
   ```

4. **Reset Docker Desktop**
   - Right-click Docker Desktop icon in system tray
   - Click "Troubleshoot"
   - Click "Reset to factory defaults"
   - Restart Docker Desktop

### Issue 2: "version is obsolete" Warning

**Symptoms:**
```
level=warning msg="docker-compose.yml: the attribute `version` is obsolete"
```

**Solution:**
This is just a warning (not an error). The `version` field is no longer needed in newer Docker Compose versions. I've already removed it from your docker-compose.yml file.

### Issue 3: Port Already in Use

**Symptoms:**
```
Error: bind: address already in use
```

**Solutions:**

1. **Find what's using the port:**
   ```powershell
   # Check port 3001 (backend)
   netstat -ano | findstr :3001
   
   # Check port 5432 (postgres)
   netstat -ano | findstr :5432
   
   # Check port 3002 (admin panel)
   netstat -ano | findstr :3002
   ```

2. **Kill the process:**
   ```powershell
   # Replace PID with the number from netstat output
   taskkill /PID <PID> /F
   ```

3. **Or change the port in docker-compose.yml:**
   ```yaml
   ports:
     - "3003:3001"  # Use 3003 instead of 3001
   ```

### Issue 4: Docker Desktop Requires Update

**Solution:**
1. Open Docker Desktop
2. Click on the gear icon (Settings)
3. Go to "Software Updates"
4. Click "Download update"
5. Restart Docker Desktop after update

### Issue 5: Insufficient Resources

**Symptoms:**
- Containers crash randomly
- "Out of memory" errors

**Solution:**
1. Open Docker Desktop
2. Click Settings (gear icon)
3. Go to "Resources"
4. Increase:
   - CPUs: At least 2
   - Memory: At least 4GB
   - Disk: At least 20GB
5. Click "Apply & Restart"

---

## Step-by-Step: First Time Docker Setup on Windows

### 1. Install Docker Desktop

1. **Download Docker Desktop**
   - Visit: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"
   - Run the installer

2. **Installation Options**
   - ✅ Enable WSL 2 (Recommended)
   - ✅ Add shortcut to desktop
   - Click "Install"

3. **Restart Computer**
   - Required after installation

### 2. Configure Docker Desktop

1. **Open Docker Desktop**
   - Start Menu → Docker Desktop

2. **Accept Terms**
   - Read and accept the service agreement

3. **Choose WSL 2 or Hyper-V**
   - WSL 2 is recommended (faster, better)
   - Hyper-V for Windows Pro/Enterprise

4. **Wait for Docker to Start**
   - Watch the whale icon in system tray
   - Should become steady (not animated)

### 3. Verify Installation

```bash
# Open PowerShell or Command Prompt

# Check Docker version
docker --version
# Expected: Docker version 20.x.x or higher

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.x.x or higher

# Test Docker
docker run hello-world
# Should download and run successfully
```

### 4. Configure Resources (Optional but Recommended)

1. Open Docker Desktop
2. Click Settings (gear icon)
3. Go to "Resources"
4. Set:
   - **CPUs**: 4 (or half of your total)
   - **Memory**: 6GB (or 1/3 of your total RAM)
   - **Disk**: 40GB
5. Click "Apply & Restart"

### 5. Start Your Project

```bash
# Navigate to project
cd D:\customer_app

# Create backend .env file
cd backend
copy .env.example .env
# Edit .env with your credentials

# Go back to root
cd ..

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Quick Fixes Checklist

Before running `docker-compose up -d`, verify:

- [ ] Docker Desktop is installed
- [ ] Docker Desktop is running (whale icon in system tray)
- [ ] Docker responds to `docker ps` command
- [ ] You're in the project root directory (D:\customer_app)
- [ ] backend/.env file exists and is configured
- [ ] No other services using ports 3001, 3002, 5432, 5050

---

## Useful Docker Desktop Features

### 1. Dashboard
- View all running containers
- See logs in real-time
- Start/stop containers with one click

### 2. Images
- View downloaded images
- Delete unused images to free space

### 3. Volumes
- View data volumes
- Backup/restore data

### 4. Settings
- Configure resources (CPU, RAM, Disk)
- Set up file sharing
- Configure network settings

---

## Alternative: Docker without Docker Desktop

If Docker Desktop doesn't work, you can use:

### Option 1: Rancher Desktop
1. Download: https://rancherdesktop.io/
2. Install and start
3. Use same docker-compose commands

### Option 2: Podman Desktop
1. Download: https://podman-desktop.io/
2. Install and start
3. Use podman-compose instead of docker-compose

### Option 3: Manual Installation (Advanced)
Install PostgreSQL manually following DATABASE_CONNECTION_GUIDE.md

---

## Getting Help

### Check Docker Status
```bash
# Is Docker running?
docker info

# View Docker events
docker events

# Check Docker logs
# Docker Desktop → Troubleshoot → View logs
```

### Docker Desktop Logs Location
```
C:\Users\<YourUsername>\AppData\Local\Docker\log.txt
```

### Community Support
- Docker Forums: https://forums.docker.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/docker
- Docker Slack: https://dockercommunity.slack.com/

---

## Summary: Fix Your Current Error

Your specific error means Docker Desktop isn't running. Here's what to do:

1. **Start Docker Desktop**
   - Press Windows Key
   - Type "Docker Desktop"
   - Click to open
   - Wait for it to fully start (30-60 seconds)

2. **Verify it's running**
   ```bash
   docker ps
   ```
   Should show empty list or running containers (not an error)

3. **Try again**
   ```bash
   cd D:\customer_app
   docker-compose up -d
   ```

4. **If still not working**
   - Restart Docker Desktop
   - Restart your computer
   - Check if WSL 2 is installed: `wsl --status`
   - Check if virtualization is enabled in BIOS

---

## Next Steps After Docker Starts

Once Docker Desktop is running:

```bash
# 1. Check Docker is working
docker ps

# 2. Navigate to project
cd D:\customer_app

# 3. Configure environment
cd backend
copy .env.example .env
notepad .env  # Edit with your Firebase credentials
cd ..

# 4. Start services
docker-compose up -d

# 5. Check status
docker-compose ps

# 6. View logs
docker-compose logs -f backend

# 7. Access services
# Backend: http://localhost:3001
# Admin Panel: http://localhost:3002
# pgAdmin: http://localhost:5050
```

---

**Last Updated**: March 8, 2026
**Status**: Complete ✅
