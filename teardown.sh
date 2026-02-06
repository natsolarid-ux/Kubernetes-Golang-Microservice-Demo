#!/bin/bash

set -e

echo "=========================================="
echo "K8s Golang Demo - Teardown"
echo "=========================================="
echo

GREEN='\033[0;32m'
NC='\033[0m'

echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/base/ingress.yaml --ignore-not-found=true
kubectl delete -f k8s/base/service.yaml --ignore-not-found=true
kubectl delete -f k8s/base/deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/base/rolebinding.yaml --ignore-not-found=true
kubectl delete -f k8s/base/role.yaml --ignore-not-found=true
kubectl delete -f k8s/base/serviceaccount.yaml --ignore-not-found=true
kubectl delete -f k8s/base/namespace.yaml --ignore-not-found=true

echo -e "${GREEN}✓ Kubernetes resources deleted${NC}"
echo

echo "To stop minikube:"
echo "  minikube stop"
echo
echo "To delete minikube cluster:"
echo "  minikube delete"
echo
echo "=========================================="
