# K8s Golang Demo - Windows Teardown Script
# Run in PowerShell

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "K8s Golang Demo - Teardown" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Deleting Kubernetes resources..." -ForegroundColor Yellow
kubectl delete -f k8s/base/ingress.yaml --ignore-not-found=true
kubectl delete -f k8s/base/service.yaml --ignore-not-found=true
kubectl delete -f k8s/base/deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/base/rolebinding.yaml --ignore-not-found=true
kubectl delete -f k8s/base/role.yaml --ignore-not-found=true
kubectl delete -f k8s/base/serviceaccount.yaml --ignore-not-found=true
kubectl delete -f k8s/base/namespace.yaml --ignore-not-found=true

Write-Host "✓ Kubernetes resources deleted" -ForegroundColor Green
Write-Host ""

Write-Host "To stop minikube:" -ForegroundColor Yellow
Write-Host "  minikube stop" -ForegroundColor Gray
Write-Host ""
Write-Host "To delete minikube cluster:" -ForegroundColor Yellow
Write-Host "  minikube delete" -ForegroundColor Gray
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
