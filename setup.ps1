# K8s Golang Demo - Windows Setup Script
# Run in PowerShell as Administrator

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "K8s Golang Demo - Windows Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

if (-not (Test-Command "minikube")) {
    Write-Host "Error: minikube is not installed" -ForegroundColor Red
    Write-Host "Install from: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Yellow
    Write-Host "Or using Chocolatey: choco install minikube" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Command "kubectl")) {
    Write-Host "Error: kubectl is not installed" -ForegroundColor Red
    Write-Host "Install from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/" -ForegroundColor Yellow
    Write-Host "Or using Chocolatey: choco install kubernetes-cli" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Command "docker")) {
    Write-Host "Error: docker is not installed" -ForegroundColor Red
    Write-Host "Install Docker Desktop from: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
    exit 1
}

Write-Host "All prerequisites met" -ForegroundColor Green
Write-Host ""

# Start minikube if not running
Write-Host "Starting minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1
if ($minikubeStatus -match "Running") {
    Write-Host "Minikube already running" -ForegroundColor Green
}
else {
    minikube start --driver=docker --cpus=2 --memory=4096
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to start minikube" -ForegroundColor Red
        exit 1
    }
    Write-Host "Minikube started" -ForegroundColor Green
}
Write-Host ""

# Enable addons
Write-Host "Enabling minikube addons..." -ForegroundColor Yellow
minikube addons enable ingress
minikube addons enable metrics-server
Write-Host "Addons enabled" -ForegroundColor Green
Write-Host ""

# Build Docker image inside minikube
Write-Host "Building Docker image..." -ForegroundColor Yellow
Write-Host "Setting Docker environment..." -ForegroundColor Gray

# Get minikube docker-env and execute it
$env:MINIKUBE_ACTIVE_DOCKERD = "minikube"
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

docker build -t data-ingestion-api:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build Docker image" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built" -ForegroundColor Green
Write-Host ""

# Create namespace
Write-Host "Creating Kubernetes resources..." -ForegroundColor Yellow
kubectl apply -f k8s/base/namespace.yaml

# Apply RBAC
kubectl apply -f k8s/base/serviceaccount.yaml
kubectl apply -f k8s/base/role.yaml
kubectl apply -f k8s/base/rolebinding.yaml

# Apply application resources
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml
kubectl apply -f k8s/base/ingress.yaml

Write-Host "Kubernetes resources created" -ForegroundColor Green
Write-Host ""

# Wait for deployment
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=120s deployment/data-ingestion-api -n data-ingestion
Write-Host "Deployment ready" -ForegroundColor Green
Write-Host ""

# Get minikube IP
$MINIKUBE_IP = minikube ip

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access the API:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Using hosts file (Recommended)" -ForegroundColor Cyan
Write-Host "  1. Open PowerShell as Administrator and run:" -ForegroundColor White
Write-Host "     Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value '$MINIKUBE_IP data-api.local'" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Test endpoints:" -ForegroundColor White
Write-Host "     curl http://data-api.local/health" -ForegroundColor Gray
Write-Host "     curl http://data-api.local/ready" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2: Using port-forward (Alternative)" -ForegroundColor Cyan
Write-Host "  1. Run port-forward:" -ForegroundColor White
Write-Host "     kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Access at: http://localhost:8080/health" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n data-ingestion" -ForegroundColor Gray
Write-Host "  kubectl logs -n data-ingestion -l app=data-ingestion-api -f" -ForegroundColor Gray
Write-Host "  kubectl describe deployment data-ingestion-api -n data-ingestion" -ForegroundColor Gray
Write-Host "  minikube dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "To tear down:" -ForegroundColor Yellow
Write-Host "  .\teardown.ps1" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
