# Kubernetes Golang Microservice Demo

A production-ready REST API microservice deployed on Kubernetes, demonstrating modern cloud-native development practices, containerization, orchestration, and observability.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/kubernetes-v1.35-blue.svg)](https://kubernetes.io/)
[![Go](https://img.shields.io/badge/go-1.21-00ADD8.svg)](https://golang.org/)
[![Docker](https://img.shields.io/badge/docker-latest-2496ED.svg)](https://www.docker.com/)

## 🎯 What This Project Does

This is a **data ingestion API** that:
- **Accepts data** via HTTP POST requests (JSON format)
- **Stores data** in-memory (up to 1000 data points)
- **Retrieves data** via HTTP GET requests
- **Exposes metrics** for Prometheus monitoring
- **Runs on Kubernetes** with multiple replicas for high availability

### Real-World Use Case
Think of this as a simplified version of systems like:
- Log aggregation services (like Datadog, Splunk)
- IoT sensor data collection
- Application metrics gathering
- Event streaming platforms

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     User / Client                        │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTP Requests
                      ▼
┌─────────────────────────────────────────────────────────┐
│              Kubernetes Cluster (Minikube)              │
│  ┌───────────────────────────────────────────────────┐  │
│  │           Ingress Controller (nginx)              │  │
│  │        Routes: data-api.local -> Service          │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                  │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │         Service (data-ingestion-api)              │  │
│  │        LoadBalancer: Port 80 -> 8080              │  │
│  └────────────────┬──────────────────┬────────────────┘  │
│                   │                  │                   │
│  ┌────────────────▼─────┐  ┌────────▼─────────────────┐ │
│  │  Pod 1 (Replica 1)   │  │  Pod 2 (Replica 2)       │ │
│  │  ┌────────────────┐  │  │  ┌────────────────┐      │ │
│  │  │ Golang API     │  │  │  │ Golang API     │      │ │
│  │  │ Port: 8080     │  │  │  │ Port: 8080     │      │ │
│  │  │ Endpoints:     │  │  │  │ Endpoints:     │      │ │
│  │  │ - /health      │  │  │  │ - /health      │      │ │
│  │  │ - /ready       │  │  │  │ - /ready       │      │ │
│  │  │ - /ingest      │  │  │  │ - /ingest      │      │ │
│  │  │ - /data        │  │  │  │ - /data        │      │ │
│  │  │ - /metrics     │  │  │  │ - /metrics     │      │ │
│  │  └────────────────┘  │  │  └────────────────┘      │ │
│  └──────────────────────┘  └──────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │        Prometheus (Optional Monitoring)            │ │
│  │     Scrapes /metrics every 30 seconds              │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

- **Language**: Go 1.21 (Golang)
- **Container**: Docker (multi-stage builds)
- **Orchestration**: Kubernetes (via Minikube)
- **Ingress**: Nginx Ingress Controller
- **Monitoring**: Prometheus metrics
- **Security**: RBAC, non-root containers, resource limits

## 📋 Prerequisites

Before starting, ensure you have:

- **Docker Desktop** 4.0+ (with WSL 2 on Windows)
  - Download: https://docs.docker.com/desktop/install/windows-install/
- **Minikube** 1.38+
  - Download: https://minikube.sigs.k8s.io/docs/start/
- **kubectl** 1.35+
  - Comes with Docker Desktop or install via: `choco install kubernetes-cli`
- **PowerShell** 5.1+ (Windows) or **Bash** 4.0+ (Linux/macOS)

## 🚀 Quick Start Guide (Step by Step)

### Windows Setup (10 Minutes)

#### Step 1: Install Prerequisites

```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Minikube
choco install minikube -y

# Install kubectl
choco install kubernetes-cli -y

# Restart PowerShell after installation
```

#### Step 2: Start Docker Desktop

1. Open **Docker Desktop** from Start Menu
2. Wait for Docker to fully start (whale icon in system tray should be steady)
3. Verify Docker is running:
   ```powershell
   docker version
   ```

#### Step 3: Clone the Repository

```powershell
# Clone the project
git clone https://github.com/natsolarid-ux/Kubernetes-Golang-Microservice-Demo.git

# Navigate to the project folder
cd Kubernetes-Golang-Microservice-Demo
```

#### Step 4: Deploy to Kubernetes

```powershell
# Run the automated setup script
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

**What this script does:**
1. ✅ Checks if Docker, Minikube, kubectl are installed
2. ✅ Starts Minikube cluster (2 CPUs, 3.5GB RAM)
3. ✅ Enables Ingress and Metrics Server addons
4. ✅ Builds Docker image inside Minikube
5. ✅ Deploys all Kubernetes resources (namespace, deployment, service, ingress)
6. ✅ Waits for pods to be ready

**Expected output:**
```
==========================================
K8s Golang Demo - Windows Setup
==========================================

Checking prerequisites...
All prerequisites met ✓

Starting minikube...
Minikube already running ✓

Building Docker image...
Docker image built ✓

Creating Kubernetes resources...
Kubernetes resources created ✓

Waiting for deployment to be ready...
Deployment ready ✓

==========================================
Setup Complete!
==========================================
```

#### Step 5: Verify Deployment

```powershell
# Check if pods are running
kubectl get pods -n data-ingestion
```

**Expected output:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
data-ingestion-api-7dc558789c-xxxxx   1/1     Running   0          2m
data-ingestion-api-7dc558789c-yyyyy   1/1     Running   0          2m
```

Both pods should show `1/1` in the READY column and `Running` in the STATUS column.

#### Step 6: Access the API

**In your current PowerShell window:**
```powershell
# Start port-forwarding (keep this running)
kubectl port-forward -n data-ingestion deployment/data-ingestion-api 8080:8080
```

**You should see:**
```
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

**⚠️ IMPORTANT:** Leave this window open and running!

#### Step 7: Test the API

**Open a NEW PowerShell window** and run:

```powershell
# Test health endpoint
curl http://localhost:8080/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "uptime": 159.89,
  "version": "1.0.0"
}
```

🎉 **Success!** Your API is running!

---

### Linux/macOS Setup (10 Minutes)

#### Step 1: Install Prerequisites

```bash
# macOS (using Homebrew)
brew install minikube kubectl

# Ubuntu/Debian
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### Step 2: Clone and Deploy

```bash
# Clone the repository
git clone https://github.com/natsolarid-ux/Kubernetes-Golang-Microservice-Demo.git
cd Kubernetes-Golang-Microservice-Demo

# Make scripts executable
chmod +x setup.sh

# Run setup
./setup.sh

# Start port-forward
kubectl port-forward -n data-ingestion deployment/data-ingestion-api 8080:8080
```

#### Step 3: Test (in a new terminal)

```bash
curl http://localhost:8080/health
```

---

## 📡 API Endpoints

### 1. Health Check
**Endpoint:** `GET /health`

**Purpose:** Check if the service is alive

```bash
curl http://localhost:8080/health
```

**Response:**
```json
{
  "status": "healthy",
  "uptime": 159.892305813,
  "version": "1.0.0"
}
```

---

### 2. Readiness Check
**Endpoint:** `GET /ready`

**Purpose:** Check if the service is ready to accept traffic

```bash
curl http://localhost:8080/ready
```

**Response:**
```json
{
  "status": "ready"
}
```

---

### 3. Ingest Data
**Endpoint:** `POST /ingest`

**Purpose:** Submit data to be stored

**PowerShell:**
```powershell
curl -Method POST -Uri http://localhost:8080/ingest `
  -ContentType "application/json" `
  -Body '{"source":"sensor-01","metrics":{"temperature":22.5,"humidity":65}}'
```

**Bash:**
```bash
curl -X POST http://localhost:8080/ingest \
  -H "Content-Type: application/json" \
  -d '{"source":"sensor-01","metrics":{"temperature":22.5,"humidity":65}}'
```

**Response:**
```json
{
  "status": "success",
  "timestamp": "2026-02-06T12:51:30.581709289Z",
  "source": "sensor-01"
}
```

---

### 4. Retrieve Data
**Endpoint:** `GET /data`

**Purpose:** Get all stored data points

```bash
curl http://localhost:8080/data
```

**Response:**
```json
{
  "count": 1,
  "data": [
    {
      "timestamp": "2026-02-06T12:51:30.581709289Z",
      "source": "sensor-01",
      "metrics": {
        "temperature": 22.5,
        "humidity": 65
      }
    }
  ]
}
```

---

### 5. Prometheus Metrics
**Endpoint:** `GET /metrics`

**Purpose:** Expose metrics for Prometheus scraping

```bash
curl http://localhost:8080/metrics
```

**Response:** (excerpt)
```
# HELP data_points_ingested_total Total number of data points ingested
# TYPE data_points_ingested_total counter
data_points_ingested_total 2

# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{endpoint="/health",method="GET",status="200"} 5
```

---

## 🧪 Complete Testing Workflow

```powershell
# 1. Ingest multiple data points
curl -Method POST -Uri http://localhost:8080/ingest -ContentType "application/json" -Body '{"source":"sensor-01","metrics":{"temp":22.5}}'

curl -Method POST -Uri http://localhost:8080/ingest -ContentType "application/json" -Body '{"source":"sensor-02","metrics":{"temp":23.1}}'

curl -Method POST -Uri http://localhost:8080/ingest -ContentType "application/json" -Body '{"source":"sensor-03","metrics":{"temp":21.8}}'

# 2. Retrieve all data
curl http://localhost:8080/data

# 3. Check health
curl http://localhost:8080/health

# 4. View metrics
curl http://localhost:8080/metrics | Select-String "data_points_ingested_total"
```

**Expected metrics output:**
```
data_points_ingested_total 3
```

---

## 🔍 What Each Component Does

### Application Layer

#### **main.go** (The API Server)
- **Purpose**: Core REST API application
- **What it does**:
  - Listens on port 8080 for HTTP requests
  - Handles 5 endpoints: `/health`, `/ready`, `/ingest`, `/data`, `/metrics`
  - Stores data in memory (Go slice with 1000-point limit)
  - Tracks request metrics (count, duration, data points)
  - Uses Prometheus client library for instrumentation

### Container Layer

#### **Dockerfile** (Container Build)
- **Purpose**: Packages the application into a Docker image
- **What it does**:
  - **Stage 1 (Builder)**: 
    - Uses `golang:1.21-alpine` base image
    - Copies `go.mod` and downloads dependencies
    - Compiles Go source code into a binary
    - Makes the binary executable with `chmod +x`
  - **Stage 2 (Runtime)**:
    - Uses minimal `alpine:latest` base (~5MB)
    - Copies only the compiled binary (no source code)
    - Adds CA certificates for HTTPS
    - Final image size: ~20MB (vs ~300MB without multi-stage)
  - **Security**: Runs as non-root user (UID 1000)

### Kubernetes Layer

#### **namespace.yaml**
- **Purpose**: Logical isolation for resources
- **What it does**: Creates "data-ingestion" namespace to separate this app from others

#### **deployment.yaml**
- **Purpose**: Defines how the application runs
- **What it does**:
  - Creates 2 pod replicas (high availability)
  - Sets resource limits: 100m CPU, 64Mi RAM per pod
  - Configures health checks:
    - **Liveness probe**: Checks `/health` every 10s (restarts if fails)
    - **Readiness probe**: Checks `/ready` every 5s (stops traffic if fails)
  - Auto-restarts pods if they crash
  - Rolling updates with zero downtime

#### **service.yaml**
- **Purpose**: Network endpoint and load balancer
- **What it does**:
  - Creates ClusterIP service (internal load balancer)
  - Distributes traffic between 2 pod replicas
  - Maps external port 80 to container port 8080
  - Provides DNS name: `data-ingestion-api.data-ingestion.svc.cluster.local`

#### **ingress.yaml**
- **Purpose**: External HTTP access
- **What it does**:
  - Routes `data-api.local` hostname to the service
  - Handles HTTP traffic from outside the cluster
  - Uses nginx ingress controller

#### **serviceaccount.yaml**
- **Purpose**: Pod identity
- **What it does**: Provides credentials for pods to interact with Kubernetes API

#### **role.yaml + rolebinding.yaml**
- **Purpose**: Security (RBAC)
- **What it does**:
  - Defines minimal permissions (read-only)
  - Allows pods to read ConfigMaps, Secrets, and Pods
  - Follows principle of least privilege

---

## 🔧 Useful Commands

### View Kubernetes Resources

```powershell
# View all pods
kubectl get pods -n data-ingestion

# View pod details
kubectl describe pod <pod-name> -n data-ingestion

# View deployment status
kubectl get deployment -n data-ingestion

# View services
kubectl get svc -n data-ingestion

# View ingress
kubectl get ingress -n data-ingestion
```

### View Logs

```powershell
# View logs from all pods
kubectl logs -n data-ingestion -l app=data-ingestion-api

# View logs from specific pod
kubectl logs -n data-ingestion <pod-name>

# Stream logs (follow mode)
kubectl logs -n data-ingestion -l app=data-ingestion-api -f
```

### Scale Deployment

```powershell
# Scale to 3 replicas
kubectl scale deployment data-ingestion-api -n data-ingestion --replicas=3

# Scale to 1 replica
kubectl scale deployment data-ingestion-api -n data-ingestion --replicas=1

# View scaling result
kubectl get pods -n data-ingestion
```

### Restart Deployment

```powershell
# Rolling restart (zero downtime)
kubectl rollout restart deployment data-ingestion-api -n data-ingestion

# Check rollout status
kubectl rollout status deployment data-ingestion-api -n data-ingestion
```

### Access Kubernetes Dashboard

```powershell
# Open dashboard in browser
minikube dashboard
```

### Stop Everything

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\teardown.ps1

# Linux/macOS
./teardown.sh
```

---

## 📊 Monitoring with Prometheus (Optional)

### Install Prometheus Stack

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\setup-prometheus.ps1

# Linux/macOS
./setup-prometheus.sh
```

### Access Prometheus

```powershell
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Open: http://localhost:9090

### Access Grafana

```powershell
# Port-forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Open: http://localhost:3000
- **Username**: `admin`
- **Password**: `prom-operator`

### Example Prometheus Queries

```promql
# Total requests
http_requests_total

# Request rate (per second)
rate(http_requests_total[5m])

# Data points ingested
data_points_ingested_total

# Request duration (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

---

## 🎓 Learning Outcomes

After completing this project, you'll understand:

1. **Containerization**
   - Docker multi-stage builds
   - Image optimization techniques
   - Security best practices (non-root users)

2. **Kubernetes Fundamentals**
   - Pods, Services, Deployments
   - ConfigMaps and Secrets
   - Namespaces for isolation

3. **Service Discovery**
   - How pods communicate
   - DNS resolution in Kubernetes
   - Service types (ClusterIP, LoadBalancer)

4. **Load Balancing**
   - Traffic distribution across replicas
   - Session affinity
   - Health-based routing

5. **Observability**
   - Prometheus metrics collection
   - Health and readiness probes
   - Logging best practices

6. **Security**
   - RBAC (Role-Based Access Control)
   - Resource limits and quotas
   - Pod security contexts

7. **DevOps Automation**
   - Infrastructure as Code
   - Automated deployment scripts
   - CI/CD pipeline concepts

---

## 🏆 Resume/Portfolio Highlights

### Project Description
"Developed and deployed a production-ready REST API microservice on Kubernetes with complete observability, high availability, and automated deployment."

### Key Achievements
- ✅ Built scalable Golang REST API with Prometheus instrumentation
- ✅ Containerized application using Docker multi-stage builds (20MB image)
- ✅ Deployed to Kubernetes with 2 replicas for 99.9% uptime
- ✅ Implemented health checks, RBAC security, and resource limits
- ✅ Configured nginx ingress for external traffic routing
- ✅ Automated deployment with shell scripts (one-command setup)
- ✅ Integrated Prometheus/Grafana for real-time monitoring
- ✅ Demonstrated zero-downtime rolling updates

### Technical Skills Demonstrated
- **Languages**: Go (Golang)
- **Containers**: Docker, multi-stage builds
- **Orchestration**: Kubernetes, Minikube
- **Networking**: Services, Ingress, DNS
- **Monitoring**: Prometheus, Grafana
- **Security**: RBAC, Pod Security Policies
- **DevOps**: Shell scripting, automation
- **Tools**: kubectl, Docker CLI, Git

---

## 🐛 Troubleshooting

### Issue: Pods Not Starting

**Check pod status:**
```powershell
kubectl get pods -n data-ingestion
```

**If status is `CrashLoopBackOff` or `Error`:**
```powershell
# View pod logs
kubectl logs -n data-ingestion <pod-name>

# View pod events
kubectl describe pod -n data-ingestion <pod-name>
```

**Common fixes:**
- Image pull errors → Check Docker is running
- Permission errors → Run `kubectl delete deployment data-ingestion-api -n data-ingestion` and redeploy
- Resource limits → Increase memory/CPU in deployment.yaml

---

### Issue: Cannot Access API

**Verify port-forward is running:**
```powershell
kubectl port-forward -n data-ingestion deployment/data-ingestion-api 8080:8080
```

**Should see:**
```
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

**If not working:**
1. Check pods are running: `kubectl get pods -n data-ingestion`
2. Pods should show `1/1 Running`
3. Restart port-forward
4. Test in a NEW window

---

### Issue: Minikube Won't Start

```powershell
# Delete and recreate
minikube delete
minikube start --driver=docker --cpus=2 --memory=3500

# If Docker Desktop has issues
# Close Docker Desktop completely
# Restart Docker Desktop
# Wait 2 minutes for full startup
# Try again
```

---

### Issue: Docker Image Build Fails

```powershell
# Ensure Docker environment is set
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Verify
docker ps

# Rebuild
docker build -t data-ingestion-api:latest .
```

---

## 📁 Project Structure

```
Kubernetes-Golang-Microservice-Demo/
├── main.go                     # Golang REST API application
├── go.mod                      # Go module dependencies
├── Dockerfile                  # Multi-stage container build
├── README.md                   # This file
├── LICENSE                     # MIT License
├── .gitignore                  # Git ignore rules
│
├── setup.ps1                   # Windows automated setup
├── setup.sh                    # Linux/macOS automated setup
├── setup.bat                   # Windows batch launcher
├── teardown.ps1                # Windows cleanup
├── teardown.sh                 # Linux/macOS cleanup
├── test.ps1                    # Windows API testing
├── test.sh                     # Linux/macOS API testing
│
├── k8s/                        # Kubernetes manifests
│   └── base/
│       ├── namespace.yaml      # Namespace definition
│       ├── deployment.yaml     # Pod deployment
│       ├── service.yaml        # Service (load balancer)
│       ├── ingress.yaml        # External routing
│       ├── serviceaccount.yaml # Pod identity
│       ├── role.yaml           # RBAC permissions
│       └── rolebinding.yaml    # RBAC binding
│   └── monitoring/
│       └── servicemonitor.yaml # Prometheus scraping
│
├── docs/                       # Documentation
│   ├── WINDOWS_SETUP.md        # Windows detailed guide
│   ├── WINDOWS_QUICKSTART.md   # Windows quick start
│   ├── TROUBLESHOOTING.md      # Common issues
│   ├── LEARNING_RESOURCES.md   # Study materials
│   └── PROJECT_SUMMARY.md      # Resume bullet points
│
└── .github/
    └── workflows/
        └── ci.yaml             # GitHub Actions CI/CD
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [Go](https://golang.org/)
- Orchestrated by [Kubernetes](https://kubernetes.io/)
- Monitored by [Prometheus](https://prometheus.io/)
- Deployed on [Minikube](https://minikube.sigs.k8s.io/)

---

## 📧 Contact & Support

**Developer**: Taz (natsolarid-ux)

**Telegram**: [@Yokan_yami](https://t.me/Yokan_yami)

**Email**: natsolarid@gmail.com

**GitHub**: [natsolarid-ux](https://github.com/natsolarid-ux)

**Project Repository**: [Kubernetes-Golang-Microservice-Demo](https://github.com/natsolarid-ux/Kubernetes-Golang-Microservice-Demo)

---

### Need Help?

💬 **Telegram**: Message me on Telegram for quick support: [@Yokan_yami](https://t.me/Yokan_yami)

🐛 **Issues**: Open an issue on GitHub if you encounter bugs

📖 **Questions**: Check the [Troubleshooting](#-troubleshooting) section first

---

## ⭐ Star This Project

If you found this helpful for learning Kubernetes and DevOps, please consider giving it a star! ⭐

---

**Made with ❤️ by Taz | DevOps Engineer & Cloud Enthusiast**
