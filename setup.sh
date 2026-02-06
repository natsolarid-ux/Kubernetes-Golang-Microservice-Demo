#!/bin/bash

set -e

echo "=========================================="
echo "K8s Golang Demo - Local Setup"
echo "=========================================="
echo

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists minikube; then
    echo -e "${RED}Error: minikube is not installed${NC}"
    echo "Install from: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo "Install from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}Error: docker is not installed${NC}"
    echo "Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo

# Start minikube if not running
echo "Starting minikube..."
if minikube status | grep -q "Running"; then
    echo -e "${GREEN}✓ Minikube already running${NC}"
else
    minikube start --driver=docker --cpus=2 --memory=4096
    echo -e "${GREEN}✓ Minikube started${NC}"
fi
echo

# Enable addons
echo "Enabling minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
echo -e "${GREEN}✓ Addons enabled${NC}"
echo

# Build Docker image inside minikube
echo "Building Docker image..."
eval $(minikube docker-env)
docker build -t data-ingestion-api:latest .
echo -e "${GREEN}✓ Docker image built${NC}"
echo

# Create namespace
echo "Creating Kubernetes resources..."
kubectl apply -f k8s/base/namespace.yaml

# Apply RBAC
kubectl apply -f k8s/base/serviceaccount.yaml
kubectl apply -f k8s/base/role.yaml
kubectl apply -f k8s/base/rolebinding.yaml

# Apply application resources
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml
kubectl apply -f k8s/base/ingress.yaml

echo -e "${GREEN}✓ Kubernetes resources created${NC}"
echo

# Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/data-ingestion-api -n data-ingestion
echo -e "${GREEN}✓ Deployment ready${NC}"
echo

# Get minikube IP
MINIKUBE_IP=$(minikube ip)

echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo
echo "Access the API:"
echo "  1. Add to /etc/hosts (run as root):"
echo "     echo \"$MINIKUBE_IP data-api.local\" | sudo tee -a /etc/hosts"
echo
echo "  2. Test endpoints:"
echo "     curl http://data-api.local/health"
echo "     curl http://data-api.local/ready"
echo "     curl -X POST http://data-api.local/ingest -H 'Content-Type: application/json' -d '{\"source\":\"test\",\"metrics\":{\"value\":123}}'"
echo "     curl http://data-api.local/data"
echo "     curl http://data-api.local/metrics"
echo
echo "  3. Port-forward for direct access (alternative):"
echo "     kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80"
echo "     Then access: http://localhost:8080/health"
echo
echo "Useful commands:"
echo "  kubectl get pods -n data-ingestion"
echo "  kubectl logs -n data-ingestion -l app=data-ingestion-api -f"
echo "  kubectl describe deployment data-ingestion-api -n data-ingestion"
echo "  minikube dashboard"
echo
echo "To tear down:"
echo "  ./scripts/teardown.sh"
echo "=========================================="
