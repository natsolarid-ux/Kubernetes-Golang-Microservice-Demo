# K8s Golang Demo - Prometheus Setup for Windows
# Run in PowerShell

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setting up Prometheus Monitoring" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Helm is installed
if (-not (Get-Command "helm" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: helm is not installed" -ForegroundColor Red
    Write-Host "Install from: https://helm.sh/docs/intro/install/" -ForegroundColor Yellow
    Write-Host "Or using Chocolatey: choco install kubernetes-helm" -ForegroundColor Yellow
    exit 1
}

# Add Prometheus Helm repo
Write-Host "Adding Prometheus Helm repository..." -ForegroundColor Yellow
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
Write-Host "✓ Helm repo added" -ForegroundColor Green
Write-Host ""

# Install Prometheus stack
Write-Host "Installing Prometheus stack..." -ForegroundColor Yellow
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm install prometheus prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false `
  --set grafana.enabled=true `
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install Prometheus" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Prometheus installed" -ForegroundColor Green
Write-Host ""

# Apply ServiceMonitor
Write-Host "Applying ServiceMonitor..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/servicemonitor.yaml
Write-Host "✓ ServiceMonitor created" -ForegroundColor Green
Write-Host ""

# Wait for Prometheus pods
Write-Host "Waiting for Prometheus pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=180s
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Prometheus Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access Prometheus:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090" -ForegroundColor Gray
Write-Host "  Then open: http://localhost:9090" -ForegroundColor White
Write-Host ""
Write-Host "Access Grafana:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80" -ForegroundColor Gray
Write-Host "  Then open: http://localhost:3000" -ForegroundColor White
Write-Host "  Default credentials: admin / prom-operator" -ForegroundColor White
Write-Host ""
Write-Host "View metrics from the API:" -ForegroundColor Yellow
Write-Host "  - http_requests_total" -ForegroundColor Gray
Write-Host "  - http_request_duration_seconds" -ForegroundColor Gray
Write-Host "  - data_points_ingested_total" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
