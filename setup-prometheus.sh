#!/bin/bash

set -e

echo "=========================================="
echo "Setting up Prometheus Monitoring"
echo "=========================================="
echo

GREEN='\033[0;32m'
NC='\033[0m'

# Add Prometheus Helm repo
echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo -e "${GREEN}✓ Helm repo added${NC}"
echo

# Install Prometheus stack
echo "Installing Prometheus stack..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

echo -e "${GREEN}✓ Prometheus installed${NC}"
echo

# Apply ServiceMonitor
echo "Applying ServiceMonitor..."
kubectl apply -f k8s/monitoring/servicemonitor.yaml
echo -e "${GREEN}✓ ServiceMonitor created${NC}"
echo

echo "Waiting for Prometheus pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=180s
echo

echo "=========================================="
echo -e "${GREEN}Prometheus Setup Complete!${NC}"
echo "=========================================="
echo
echo "Access Prometheus:"
echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "  Then open: http://localhost:9090"
echo
echo "Access Grafana:"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Then open: http://localhost:3000"
echo "  Default credentials: admin / prom-operator"
echo
echo "View metrics from the API:"
echo "  - http_requests_total"
echo "  - http_request_duration_seconds"
echo "  - data_points_ingested_total"
echo "=========================================="
