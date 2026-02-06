# Troubleshooting Guide

Common issues and their solutions when deploying this demo project.

## 🔍 General Debugging Commands

```bash
# Check pod status
kubectl get pods -n data-ingestion

# Describe pod for events
kubectl describe pod <pod-name> -n data-ingestion

# View logs
kubectl logs -n data-ingestion -l app=data-ingestion-api -f

# Get events
kubectl get events -n data-ingestion --sort-by='.lastTimestamp'

# Check if services are running
kubectl get svc -n data-ingestion

# Check ingress
kubectl get ingress -n data-ingestion
kubectl describe ingress data-ingestion-ingress -n data-ingestion
```

## 🐛 Common Issues

### Issue 1: Minikube Won't Start

**Symptoms:**
```
❌ Exiting due to PROVIDER_DOCKER_NOT_RUNNING: docker is not running
```

**Solution:**
```bash
# Start Docker Desktop first
# Then start minikube
minikube start --driver=docker

# Or use different driver
minikube start --driver=hyperkit  # macOS
minikube start --driver=virtualbox
```

### Issue 2: ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods -n data-ingestion
NAME                                   READY   STATUS             RESTARTS
data-ingestion-api-xxx                 0/1     ImagePullBackOff   0
```

**Solution:**
```bash
# Make sure you built the image in minikube's Docker daemon
eval $(minikube docker-env)
docker build -t data-ingestion-api:latest .

# Verify image exists
docker images | grep data-ingestion-api

# If still failing, check deployment imagePullPolicy
kubectl edit deployment data-ingestion-api -n data-ingestion
# Change: imagePullPolicy: Always -> imagePullPolicy: IfNotPresent
```

### Issue 3: CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods -n data-ingestion
NAME                                   READY   STATUS             RESTARTS
data-ingestion-api-xxx                 0/1     CrashLoopBackOff   5
```

**Solution:**
```bash
# Check logs for error
kubectl logs data-ingestion-api-xxx -n data-ingestion

# Common causes:
# 1. Port already in use - check PORT env var
# 2. Missing dependencies - check go.mod
# 3. Application error - check main.go code

# Debug by running locally first
go run main.go
```

### Issue 4: Ingress Not Working

**Symptoms:**
```bash
curl http://data-api.local/health
# curl: (7) Failed to connect to data-api.local
```

**Solution:**
```bash
# 1. Check if ingress addon is enabled
minikube addons list | grep ingress

# If not enabled
minikube addons enable ingress

# 2. Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# 3. Verify /etc/hosts entry
cat /etc/hosts | grep data-api.local
# Should show: <minikube-ip> data-api.local

# Add if missing
echo "$(minikube ip) data-api.local" | sudo tee -a /etc/hosts

# 4. Check ingress resource
kubectl get ingress -n data-ingestion
kubectl describe ingress data-ingestion-ingress -n data-ingestion

# 5. Alternative: Use NodePort instead
kubectl patch svc data-ingestion-api -n data-ingestion -p '{"spec":{"type":"NodePort"}}'
minikube service data-ingestion-api -n data-ingestion --url
```

### Issue 5: Pods Not Ready

**Symptoms:**
```bash
kubectl get pods -n data-ingestion
NAME                                   READY   STATUS    RESTARTS
data-ingestion-api-xxx                 0/1     Running   0
```

**Solution:**
```bash
# Check readiness probe
kubectl describe pod data-ingestion-api-xxx -n data-ingestion

# Common issues:
# 1. Probe endpoint not responding
curl http://<pod-ip>:8080/ready

# 2. Probe timing too aggressive
# Edit deployment to increase initialDelaySeconds
kubectl edit deployment data-ingestion-api -n data-ingestion

# 3. Application not listening on correct port
kubectl logs data-ingestion-api-xxx -n data-ingestion
```

### Issue 6: Permission Denied Errors

**Symptoms:**
```bash
Error: failed to create containerd task: failed to create shim task: 
OCI runtime create failed: runc create failed: unable to start container process: 
exec: "./main": permission denied
```

**Solution:**
```bash
# In Dockerfile, ensure binary is executable
# Add before COPY in Dockerfile:
RUN chmod +x /app/main

# Or in multi-stage build:
COPY --from=builder --chmod=0755 /app/main .
```

### Issue 7: Port-Forward Not Working

**Symptoms:**
```bash
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80
# Connection refused or timeouts
```

**Solution:**
```bash
# 1. Check if service exists
kubectl get svc -n data-ingestion

# 2. Check if pods are running
kubectl get pods -n data-ingestion

# 3. Use pod directly instead of service
kubectl port-forward -n data-ingestion pod/<pod-name> 8080:8080

# 4. Check for port conflicts locally
lsof -i :8080
# Kill process if needed

# 5. Try different port
kubectl port-forward -n data-ingestion svc/data-ingestion-api 9090:80
curl http://localhost:9090/health
```

### Issue 8: Prometheus Not Scraping Metrics

**Symptoms:**
- Metrics not appearing in Prometheus UI
- ServiceMonitor created but no data

**Solution:**
```bash
# 1. Verify ServiceMonitor is created
kubectl get servicemonitor -n data-ingestion

# 2. Check Prometheus target discovery
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090/targets
# Look for data-ingestion-api targets

# 3. Check if service has correct labels
kubectl get svc data-ingestion-api -n data-ingestion --show-labels

# 4. Verify metrics endpoint is accessible
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80
curl http://localhost:8080/metrics

# 5. Check Prometheus operator logs
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus-operator -f
```

### Issue 9: Resource Exhaustion

**Symptoms:**
```bash
Warning  FailedScheduling  pod/data-ingestion-api-xxx  
0/1 nodes are available: 1 Insufficient memory.
```

**Solution:**
```bash
# 1. Check node resources
kubectl describe node minikube

# 2. Reduce resource requests in deployment
kubectl edit deployment data-ingestion-api -n data-ingestion
# Change:
#   requests:
#     memory: 64Mi -> 32Mi
#     cpu: 100m -> 50m

# 3. Increase minikube resources
minikube stop
minikube delete
minikube start --cpus=4 --memory=8192

# 4. Check what's using resources
kubectl top nodes
kubectl top pods -A
```

### Issue 10: DNS Resolution Issues

**Symptoms:**
```bash
# Inside pod
nslookup data-ingestion-api
# server can't find data-ingestion-api: NXDOMAIN
```

**Solution:**
```bash
# 1. Check CoreDNS is running
kubectl get pods -n kube-system -l k8s-app=kube-dns

# 2. Test DNS from inside a pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
nslookup kubernetes.default
nslookup data-ingestion-api.data-ingestion.svc.cluster.local

# 3. Restart CoreDNS if needed
kubectl rollout restart deployment coredns -n kube-system

# 4. Check service exists
kubectl get svc -n data-ingestion data-ingestion-api
```

## 🛠️ Quick Fixes

### Reset Everything

```bash
# Complete teardown and restart
./teardown.sh
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096
./setup.sh
```

### Rebuild and Redeploy

```bash
# Rebuild image
eval $(minikube docker-env)
docker build -t data-ingestion-api:latest .

# Delete and recreate pods
kubectl delete pods -n data-ingestion -l app=data-ingestion-api

# Or restart deployment
kubectl rollout restart deployment data-ingestion-api -n data-ingestion
```

### View All Resources

```bash
# Everything in namespace
kubectl get all -n data-ingestion

# With more details
kubectl get all,ingress,servicemonitor -n data-ingestion -o wide
```

## 📊 Health Checks

### Quick Status Check

```bash
#!/bin/bash
echo "=== Minikube Status ==="
minikube status

echo -e "\n=== Pods Status ==="
kubectl get pods -n data-ingestion

echo -e "\n=== Service Status ==="
kubectl get svc -n data-ingestion

echo -e "\n=== Ingress Status ==="
kubectl get ingress -n data-ingestion

echo -e "\n=== Recent Events ==="
kubectl get events -n data-ingestion --sort-by='.lastTimestamp' | tail -5
```

Save as `status.sh` and run: `./status.sh`

## 🔐 RBAC Troubleshooting

### Check Service Account Permissions

```bash
# Get service account token
SA_TOKEN=$(kubectl get secret -n data-ingestion \
  $(kubectl get sa data-ingestion-sa -n data-ingestion -o jsonpath='{.secrets[0].name}') \
  -o jsonpath='{.data.token}' | base64 -d)

# Test if SA can list pods (should fail with current RBAC)
kubectl auth can-i list pods --as=system:serviceaccount:data-ingestion:data-ingestion-sa -n data-ingestion

# Test what SA can do
kubectl auth can-i --list --as=system:serviceaccount:data-ingestion:data-ingestion-sa -n data-ingestion
```

## 📝 Logs and Debugging

### Enable Debug Logging

```bash
# Add debug logs to Go app
# In main.go, add:
# log.SetFlags(log.LstdFlags | log.Lshortfile)

# Rebuild and deploy
eval $(minikube docker-env)
docker build -t data-ingestion-api:latest .
kubectl rollout restart deployment data-ingestion-api -n data-ingestion
```

### Aggregate Logs

```bash
# All pods logs
kubectl logs -n data-ingestion -l app=data-ingestion-api --all-containers=true -f

# With stern (if installed)
stern -n data-ingestion data-ingestion-api
```

## 🆘 Getting Help

If you're still stuck:

1. **Check logs**: `kubectl logs <pod-name> -n data-ingestion`
2. **Describe resources**: `kubectl describe <resource> <name> -n data-ingestion`
3. **Check events**: `kubectl get events -n data-ingestion`
4. **Search GitHub issues**: Many common problems have been solved
5. **Kubernetes Slack**: https://kubernetes.slack.com/
6. **Stack Overflow**: Tag questions with [kubernetes] [minikube] [golang]

## 📚 Additional Resources

- [Kubernetes Troubleshooting Guide](https://kubernetes.io/docs/tasks/debug/)
- [kubectl Debug Guide](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-running-pods)
- [Minikube Troubleshooting](https://minikube.sigs.k8s.io/docs/drivers/docker/#troubleshooting)
