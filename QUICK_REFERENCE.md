# Quick Reference Card

## 🚀 One-Command Deployment
```bash
./setup.sh
```

## 🧪 Test Everything
```bash
./test.sh http://data-api.local
```

## 📊 Access Services

### API (via Ingress)
```bash
curl http://data-api.local/health
curl http://data-api.local/metrics
curl -X POST http://data-api.local/ingest \
  -H "Content-Type: application/json" \
  -d '{"source":"test","metrics":{"value":123}}'
```

### API (via Port-Forward)
```bash
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80
curl http://localhost:8080/health
```

### Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090
```

### Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open: http://localhost:3000
# Login: admin / prom-operator
```

## 🔍 Debug Commands

### Pod Status
```bash
kubectl get pods -n data-ingestion
kubectl describe pod <pod-name> -n data-ingestion
kubectl logs -n data-ingestion -l app=data-ingestion-api -f
```

### Events
```bash
kubectl get events -n data-ingestion --sort-by='.lastTimestamp'
```

### Resources
```bash
kubectl get all,ingress,servicemonitor -n data-ingestion
kubectl top pods -n data-ingestion
```

## 🛠️ Common Operations

### Rebuild & Redeploy
```bash
eval $(minikube docker-env)
docker build -t data-ingestion-api:latest .
kubectl rollout restart deployment data-ingestion-api -n data-ingestion
```

### Scale
```bash
kubectl scale deployment data-ingestion-api -n data-ingestion --replicas=3
```

### Update Image
```bash
kubectl set image deployment/data-ingestion-api api=data-ingestion-api:v2 -n data-ingestion
```

## 🧹 Cleanup
```bash
./teardown.sh
minikube stop
minikube delete
```

## 📁 Project Structure
```
k8s-golang-demo/
├── main.go                 # Go application
├── Dockerfile              # Container image
├── setup.sh                # One-command deploy
├── test.sh                 # API tests
├── k8s/
│   ├── base/              # K8s manifests
│   └── monitoring/        # Prometheus config
├── README.md              # Full documentation
├── LEARNING_RESOURCES.md  # Study guide
└── TROUBLESHOOTING.md     # Debug guide
```

## 🎯 Key Metrics
- **Deployment Time**: < 5 minutes
- **Image Size**: ~20MB
- **Memory**: 64Mi per pod
- **CPU**: 100m per pod
- **Replicas**: 2 (default)

## 🔗 Important URLs
- API: `http://data-api.local`
- Prometheus: `http://localhost:9090` (after port-forward)
- Grafana: `http://localhost:3000` (after port-forward)
- Minikube Dashboard: `minikube dashboard`

## 💡 Pro Tips
1. Use `k9s` for better K8s UI: `brew install k9s`
2. Use `stern` for log aggregation: `brew install stern`
3. Check `TROUBLESHOOTING.md` for common issues
4. Reference `LEARNING_RESOURCES.md` for study materials

## 🆘 Emergency Commands
```bash
# Full reset
./teardown.sh && minikube delete && minikube start && ./setup.sh

# Quick restart
kubectl delete pods -n data-ingestion -l app=data-ingestion-api

# Check everything
kubectl get all,ingress,pv,pvc,configmap,secret -n data-ingestion
```
