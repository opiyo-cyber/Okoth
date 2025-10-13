# YOLO E-Commerce Application - Deployment Guide

## 📋 Prerequisites

Before running the application, ensure you have the following installed:

### Required Software
- **Docker Engine** (v20.0 or higher)
- **Docker Compose** (v2.0 or higher)
- **Git** (for cloning the repository)

### System Requirements
- **RAM**: Minimum 2GB available
- **Disk Space**: At least 2GB free space
- **Ports**: 3002, 5001, and 27017 must be available

### Installation Links
- [Docker Desktop](https://docs.docker.com/desktop/) (includes Docker Compose)
- [Docker Engine (Linux)](https://docs.docker.com/engine/install/)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd yolo
```

### 2. Start the Application
```bash
docker-compose up -d
```

### 3. Access the Application
- **Frontend**: http://localhost:3002
- **Backend API**: http://localhost:5001/api/products
- **Database**: localhost:27017

## 📖 Detailed Setup Instructions

### Step 1: Verify Docker Installation
```bash
# Check Docker version
docker --version
# Should return: Docker version 20.x.x or higher

# Check Docker Compose version
docker-compose --version
# Should return: Docker Compose version 2.x.x or higher

# Test Docker is running
docker ps
# Should return empty list or running containers
```

### Step 2: Download the Project
```bash
# Option A: Clone from Git
git clone <your-repository-url>
cd yolo

# Option B: Extract from ZIP
unzip yolo-project.zip
cd yolo
```

### Step 3: Build and Start Services
```bash
# Build and start all services in detached mode
docker-compose up -d --build

# View startup logs (optional)
docker-compose logs -f
```

### Step 4: Verify Deployment
```bash
# Check all containers are running
docker-compose ps

# Test frontend
curl http://localhost:3002

# Test backend API
curl http://localhost:5001/api/products
```

## 🔧 Configuration Options

### Port Configuration
If default ports are occupied, modify `docker-compose.yaml`:

```yaml
services:
  brian-yolo-client:
    ports:
      - "3003:3000"  # Change host port from 3002 to 3003

  brian-yolo-backend:
    ports:
      - "5002:5000"  # Change host port from 5001 to 5002
```

### Environment Variables
Create `.env` file in project root for custom configuration:
```bash
# Database Configuration
MONGODB_URI=mongodb://app-ip-mongo/yolomy
DB_NAME=yolomy

# Application Ports
FRONTEND_PORT=3002
BACKEND_PORT=5001
MONGO_PORT=27017

# Node Environment
NODE_ENV=production
```

## 🗂️ Project Structure
```
yolo/
├── docker-compose.yaml     # Multi-container orchestration
├── explanation.md          # Technical documentation
├── deployment-status.md    # Deployment verification
├── DEPLOYMENT-GUIDE.md    # This file
├── backend/               # Node.js/Express API
│   ├── Dockerfile        # Backend container definition
│   ├── server.js         # Main server file
│   ├── package.json      # Dependencies
│   ├── models/           # Database models
│   └── routes/           # API routes
└── client/               # React frontend
    ├── Dockerfile        # Frontend container definition
    ├── package.json      # React dependencies
    ├── public/           # Static assets
    └── src/              # React components
```

## 📊 Service Details

### Frontend Service (React)
- **Container**: `brian-yolo-client`
- **Image**: `brianbwire/brian-yolo-client:v1.0.0`
- **Port**: 3002 (host) → 3000 (container)
- **Size**: 302MB
- **Technology**: React 16.13.1

### Backend Service (Node.js)
- **Container**: `brian-yolo-backend`
- **Image**: `brianbwire/brian-yolo-backend:v1.0.0`
- **Port**: 5001 (host) → 5000 (container)
- **Size**: 80.8MB
- **Technology**: Node.js 14 + Express

### Database Service (MongoDB)
- **Container**: `app-mongo`
- **Image**: `mongo:latest`
- **Port**: 27017 (host) → 27017 (container)
- **Size**: 910MB
- **Data Volume**: `app-mongo-data`

## 🌐 API Endpoints

### Products API
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products |
| POST | `/api/products` | Create new product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |

### Example API Usage
```bash
# Get all products
curl http://localhost:5001/api/products

# Add a new product
curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"Test Product","description":"Test description","price":99.99,"quantity":10}' \
  http://localhost:5001/api/products

# Update a product
curl -X PUT -H "Content-Type: application/json" \
  -d '{"name":"Updated Product","price":149.99}' \
  http://localhost:5001/api/products/PRODUCT_ID
```

## 🔄 Management Commands

### Start Application
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d brian-yolo-backend

# Start with rebuild
docker-compose up -d --build
```

### Stop Application
```bash
# Stop all services
docker-compose down

# Stop but keep volumes
docker-compose stop

# Stop and remove volumes (⚠️ DATA LOSS)
docker-compose down -v
```

### Monitor Application
```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs brian-yolo-backend
```

### Scale Services
```bash
# Scale backend to 3 instances
docker-compose up -d --scale brian-yolo-backend=3

# Scale frontend to 2 instances
docker-compose up -d --scale brian-yolo-client=2
```

## 🛠️ Development Mode

### Hot Reload Development
For development with code changes:

```bash
# 1. Stop production containers
docker-compose down

# 2. Mount source code as volumes (modify docker-compose.yaml)
# Add under each service:
volumes:
  - ./backend:/app  # For backend
  - ./client/src:/app/src  # For frontend

# 3. Start in development mode
docker-compose up -d
```

### Debugging
```bash
# Access container shell
docker exec -it brian-yolo-backend sh
docker exec -it brian-yolo-client sh

# View container resources
docker stats

# Inspect container configuration
docker inspect brian-yolo-backend
```

## 🔍 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Error: "bind: address already in use"
# Solution: Kill process using the port
sudo lsof -i :3002
sudo kill -9 <PID>

# Or change port in docker-compose.yaml
```

#### MongoDB Connection Failed
```bash
# Check if MongoDB is running
docker logs app-mongo

# Verify network connectivity
docker exec brian-yolo-backend ping app-ip-mongo

# Check MongoDB connection string in backend/server.js
```

#### Frontend Not Loading
```bash
# Check if React build completed
docker logs brian-yolo-client

# Verify frontend container is running
docker ps | grep client

# Access frontend container
docker exec -it brian-yolo-client sh
```

#### Out of Disk Space
```bash
# Remove unused Docker resources
docker system prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
docker system df
```

### Health Checks
```bash
# Frontend health check
curl -f http://localhost:3002 || echo "Frontend down"

# Backend health check
curl -f http://localhost:5001/api/products || echo "Backend down"

# Database health check
docker exec app-mongo mongo --eval "db.runCommand('ping')" || echo "Database down"
```

## 📈 Performance Optimization

### Resource Limits
Add to `docker-compose.yaml`:
```yaml
services:
  brian-yolo-backend:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          memory: 256M
```

### Production Optimization
```bash
# Build optimized images
docker-compose build --no-cache

# Remove development dependencies
docker exec brian-yolo-backend npm prune --production

# Enable production mode
export NODE_ENV=production
docker-compose up -d
```

## 🔐 Security Considerations

### Network Security
- Application runs on isolated Docker network
- Only necessary ports exposed to host
- Internal service communication encrypted

### Data Security
- MongoDB data persisted in named volume
- No secrets hardcoded in images
- Use environment variables for sensitive data

### Updates
```bash
# Update base images
docker-compose pull

# Rebuild with security patches
docker-compose build --pull --no-cache

# Restart with new images
docker-compose up -d
```

## 📦 Backup and Restore

### Backup Database
```bash
# Create database backup
docker exec app-mongo mongodump --out /backup

# Copy backup from container
docker cp app-mongo:/backup ./mongo-backup
```

### Restore Database
```bash
# Copy backup to container
docker cp ./mongo-backup app-mongo:/backup

# Restore database
docker exec app-mongo mongorestore /backup
```

### Backup Application Images
```bash
# Save images to tar files
docker save brianbwire/brian-yolo-client:v1.0.0 | gzip > yolo-client.tar.gz
docker save brianbwire/brian-yolo-backend:v1.0.0 | gzip > yolo-backend.tar.gz

# Load images from tar files
gunzip -c yolo-client.tar.gz | docker load
gunzip -c yolo-backend.tar.gz | docker load
```

## 🎯 Quick Commands Summary

```bash
# Essential commands
docker-compose up -d          # Start application
docker-compose down           # Stop application
docker-compose ps            # Check status
docker-compose logs          # View logs
docker-compose restart       # Restart services

# Development commands
docker-compose up -d --build # Rebuild and start
docker-compose logs -f       # Follow logs
docker exec -it <container> sh # Access container

# Maintenance commands
docker system prune          # Clean unused resources
docker volume ls             # List volumes
docker network ls            # List networks
```

---

## 🆘 Support

For issues or questions:
1. Check the logs: `docker-compose logs`
2. Verify all containers are running: `docker-compose ps`
3. Check the troubleshooting section above
4. Review the technical documentation in `explanation.md`

**🎉 Your YOLO e-commerce application should now be running successfully!**

Access it at: **http://localhost:3002**