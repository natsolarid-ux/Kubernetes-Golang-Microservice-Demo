# Kubernetes Golang Demo - Data Ingestion Microservice

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.21-blue.svg)](https://golang.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5.svg)](https://kubernetes.io/)

A production-ready Golang REST API microservice demonstrating modern DevOps/SRE practices including containerization, Kubernetes orchestration, RBAC, Ingress routing, and Prometheus monitoring.

## 🚀 Features

- **REST API**: Data ingestion endpoints with JSON validation
- **Prometheus Metrics**: Built-in instrumentation for observability
- **Health Checks**: Kubernetes-ready liveness and readiness probes
- **Docker**: Multi-stage builds for minimal image size
- **Kubernetes**: Complete manifests with RBAC, Ingress, and resource limits
- **Local Development**: Easy setup with Minikube
- **Security**: Non-root containers, read-only filesystems, dropped capabilities

## 📋 Prerequisites

### Linux/macOS
- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (1.30+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (1.28+)
- [Helm](https://helm.sh/docs/intro/install/) (3.0+) - for Prometheus setup
- [Go](https://golang.org/doc/install) (1.21+) - for local development
- [jq](https://stedolan.github.io/jq/) - for testing scripts

### Windows
- [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
- PowerShell 5.1 or later
- **See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for detailed Windows installation guide**

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Minikube Cluster                      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                   Ingress Controller                    │ │
│  │              (nginx.ingress.kubernetes.io)              │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│                         │                                    │
│  ┌──────────────────────▼──────────────────────────────────┐ │
│  │           Service: data-ingestion-api (ClusterIP)        │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│                         │                                    │
│  ┌──────────────────────▼──────────────────────────────────┐ │
│  │        Deployment: data-ingestion-api (2 replicas)       │ │
│  │                                                          │ │
│  │  ┌──────────────┐              ┌──────────────┐         │ │
│  │  │   Pod 1      │              │   Pod 2      │         │ │
│  │  │              │              │              │         │ │
│  │  │  Container:  │              │  Container:  │         │ │
│  │  │  Golang API  │              │  Golang API  │         │ │
│  │  │  Port: 8080  │              │  Port: 8080  │         │ │
│  │  └──────────────┘              └──────────────┘         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              RBAC (ServiceAccount + Role)                │ │
│  │          Limited permissions for security                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │         Prometheus Monitoring (Optional)                 │ │
│  │      ServiceMonitor → Scrapes /metrics endpoint          │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 API Endpoints

| Method | Endpoint   | Description                    |
|--------|-----------|--------------------------------|
| GET    | `/health`  | Health check with uptime       |
| GET    | `/ready`   | Readiness probe                |
| POST   | `/ingest`  | Ingest data points (JSON)      |
| GET    | `/data`    | Retrieve stored data           |
| GET    | `/metrics` | Prometheus metrics             |

### Sample Request

```bash
curl -X POST http://data-api.local/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "source": "sensor-001",
    "metrics": {
      "temperature": 23.5,
      "humidity": 65.2,
      "pressure": 1013.25
    }
  }'
```

### Sample Response

```json
{
  "status": "success",
  "timestamp": "2025-02-05T14:30:45Z",
  "source": "sensor-001"
}
```

## 🚀 Quick Start

### Linux/macOS

```bash
git clone https://github.com/yourusername/k8s-golang-demo.git
cd k8s-golang-demo
```

### 2. Deploy to Minikube

**Linux/macOS:**
```bash
./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

This script will:
- ✅ Check prerequisites (docker, kubectl, minikube)
- ✅ Start Minikube cluster
- ✅ Enable Ingress and metrics-server addons
- ✅ Build Docker image
- ✅ Create namespace and RBAC resources
- ✅ Deploy application with 2 replicas
- ✅ Configure Ingress routing

### 3. Configure Local Access

**Linux/macOS:**
Add the following to `/etc/hosts`:

```bash
echo "$(minikube ip) data-api.local" | sudo tee -a /etc/hosts
```

**Windows (PowerShell as Administrator):**
```powershell
$minikubeIP = minikube ip
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "$minikubeIP data-api.local"
```

### 4. Test the API

**Using Ingress:**
```bash
# Using Ingress
curl http://data-api.local/health

# Or using port-forward
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80
curl http://localhost:8080/health

# Run comprehensive tests (Linux/macOS)
./test.sh http://data-api.local

# Run comprehensive tests (Windows)
# .\test.ps1 http://data-api.local
```

## 📊 Prometheus Monitoring (Optional)

Install Prometheus and Grafana:

```bash
./setup-prometheus.sh
```

Access dashboards:

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090

# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open: http://localhost:3000
# Credentials: admin / prom-operator
```

### Available Metrics

- `http_requests_total` - Total HTTP requests by method, endpoint, status
- `http_request_duration_seconds` - Request latency histogram
- `data_points_ingested_total` - Total data points ingested

### Sample PromQL Queries

```promql
# Request rate per second
rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status=~"5.."}[5m])
```

## 🔧 Development

### Local Development (without K8s)

```bash
# Install dependencies
go mod download

# Run locally
go run main.go

# Test
curl http://localhost:8080/health
```

### Build Docker Image

```bash
docker build -t data-ingestion-api:latest .
```

### Run with Docker

```bash
docker run -p 8080:8080 data-ingestion-api:latest
```

## 📁 Project Structure

```
k8s-golang-demo/
├── main.go                      # Go application code
├── go.mod                       # Go dependencies
├── Dockerfile                   # Multi-stage Docker build
├── setup.sh                     # Quick setup script
├── teardown.sh                  # Cleanup script
├── test.sh                      # API testing script
├── setup-prometheus.sh          # Prometheus installation
├── k8s/
│   ├── base/
│   │   ├── namespace.yaml       # Namespace definition
│   │   ├── deployment.yaml      # Application deployment
│   │   ├── service.yaml         # ClusterIP service
│   │   ├── serviceaccount.yaml  # RBAC service account
│   │   ├── role.yaml            # RBAC role
│   │   ├── rolebinding.yaml     # RBAC role binding
│   │   └── ingress.yaml         # Ingress routing
│   └── monitoring/
│       └── servicemonitor.yaml  # Prometheus ServiceMonitor
└── README.md
```

## 🔒 Security Features

- **Non-root containers**: Runs as user ID 1000
- **Read-only filesystem**: Prevents runtime modifications
- **Dropped capabilities**: ALL capabilities dropped
- **Resource limits**: CPU and memory constraints
- **RBAC**: Minimal permissions (read-only access to ConfigMaps/Secrets)
- **Security context**: Multiple layers of security controls

## 🛠️ Useful Commands

### Kubernetes

```bash
# View pods
kubectl get pods -n data-ingestion

# View logs
kubectl logs -n data-ingestion -l app=data-ingestion-api -f

# Describe deployment
kubectl describe deployment data-ingestion-api -n data-ingestion

# Scale deployment
kubectl scale deployment data-ingestion-api -n data-ingestion --replicas=3

# Port-forward
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80

# Access pod shell
kubectl exec -it -n data-ingestion deployment/data-ingestion-api -- /bin/sh
```

### Minikube

```bash
# Start cluster
minikube start

# Stop cluster
minikube stop

# Delete cluster
minikube delete

# View dashboard
minikube dashboard

# Get cluster IP
minikube ip

# SSH into node
minikube ssh
```

## 📚 Learning Resources

### Kubernetes
- [Official Documentation](https://kubernetes.io/docs/home/)
- [Kubernetes in Action (book)](https://www.manning.com/books/kubernetes-in-action-second-edition)
- [CKAD Prep](https://github.com/dgkanatsios/CKAD-exercises)
- [Killer.sh CKAD Simulator](https://killer.sh/)

### Golang
- [Official Go Tour](https://tour.golang.org/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://golang.org/doc/effective_go)

### Tools
- [Minikube Tutorials](https://minikube.sigs.k8s.io/docs/tutorials/)
- [Kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/)
- [K9s (Terminal UI)](https://k9scli.io/)

## 🧪 Testing

### Run All Tests

```bash
# Deploy and test
./setup.sh
./test.sh http://data-api.local

# Port-forward and test locally
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80 &
./test.sh http://localhost:8080
```

### Manual Testing

```bash
# Health check
curl http://data-api.local/health

# Ingest data
curl -X POST http://data-api.local/ingest \
  -H "Content-Type: application/json" \
  -d '{"source":"manual-test","metrics":{"value":42}}'

# Retrieve data
curl http://data-api.local/data | jq .

# View metrics
curl http://data-api.local/metrics
```

## 🧹 Cleanup

Remove all resources:

```bash
./teardown.sh

# Optional: Stop/delete Minikube
minikube stop
minikube delete
```

## 🔮 Future Enhancements

- [ ] PostgreSQL/Redis integration for persistent storage
- [ ] gRPC support alongside REST
- [ ] Distributed tracing with Jaeger/Tempo
- [ ] GitOps with ArgoCD/Flux
- [ ] Helm chart for easier deployment
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] E2E tests with automated deployment
- [ ] HorizontalPodAutoscaler configuration
- [ ] NetworkPolicy for network segmentation
- [ ] TLS/mTLS with cert-manager

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with**: Go, Docker, Kubernetes, Prometheus, Minikube

**Purpose**: DevOps/SRE portfolio demonstration project showcasing modern cloud-native practices
