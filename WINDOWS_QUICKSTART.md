# 🪟 Windows Quick Start

**Complete Windows setup in 10 minutes!**

## ⚡ Super Fast Setup

### Prerequisites (5 minutes)

1. **Install Docker Desktop**
   - Download: https://www.docker.com/products/docker-desktop/
   - Install and restart computer
   - Start Docker Desktop (check system tray icon)

2. **Install Minikube & kubectl** (via Chocolatey - easiest)
   
   Open PowerShell **as Administrator**:
   ```powershell
   # Install Chocolatey (if not already installed)
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   
   # Install tools
   choco install -y minikube kubernetes-cli
   ```

3. **Verify Installation**
   ```powershell
   docker --version
   minikube version
   kubectl version --client
   ```

### Deploy the Project (2 minutes)

1. **Extract and Navigate**
   ```powershell
   # Extract k8s-golang-demo.tar.gz using Windows Explorer or:
   tar -xzf k8s-golang-demo.tar.gz
   cd k8s-golang-demo
   ```

2. **Run Setup**
   
   **Option A - Double-click** `setup.bat` (right-click → Run as Administrator)
   
   **Option B - PowerShell** (as Administrator):
   ```powershell
   .\setup.ps1
   ```

3. **Configure Access**
   
   Still in PowerShell as Administrator:
   ```powershell
   # Add to hosts file
   $minikubeIP = minikube ip
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "$minikubeIP data-api.local"
   ```

4. **Test It!**
   ```powershell
   # Test health endpoint
   curl http://data-api.local/health
   
   # Run full test suite
   .\test.ps1 http://data-api.local
   ```

## 🎉 Done! Your API is Running!

Access your API at: **http://data-api.local**

### Quick Commands

```powershell
# View running pods
kubectl get pods -n data-ingestion

# View logs
kubectl logs -n data-ingestion -l app=data-ingestion-api -f

# Open Kubernetes dashboard
minikube dashboard

# Test the API
curl http://data-api.local/health
curl http://data-api.local/metrics
```

## 📊 Add Monitoring (Optional - 3 minutes)

```powershell
# Install Helm first
choco install -y kubernetes-helm

# Setup Prometheus and Grafana
.\setup-prometheus.ps1

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open: http://localhost:3000
# Login: admin / prom-operator
```

## 🧹 Cleanup

```powershell
# Remove everything
.\teardown.ps1
minikube delete
```

## ❗ Troubleshooting

### "Docker not running"
→ Start Docker Desktop, wait for it to fully load (whale icon in system tray)

### "Cannot be loaded because running scripts is disabled"
→ Run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### "Minikube won't start"
→ Make sure Docker Desktop is running
→ Try: `minikube delete` then `minikube start --driver=docker`

### "Port 8080 already in use"
→ Run: `netstat -ano | findstr :8080` to find the process
→ Kill it: `taskkill /PID <PID> /F`

### Need help?
→ See detailed guide: `WINDOWS_SETUP.md`
→ Troubleshooting: `TROUBLESHOOTING.md`

## 📚 Next Steps

1. ✅ Project is deployed and running
2. 📝 Read through `README.md` for full documentation
3. 🎓 Check `LEARNING_RESOURCES.md` for study materials
4. 🚀 Push to GitHub and add to your portfolio
5. 💼 Update resume with this project

**Congratulations! You now have a production-ready Kubernetes microservice running locally! 🎊**
