# Windows Installation Guide

Complete setup guide for deploying the K8s Golang Demo on Windows.

## 📋 Prerequisites Installation

### Required Software

1. **Docker Desktop** (Required)
   - Download: https://docs.docker.com/desktop/install/windows-install/
   - Minimum: Windows 10 64-bit (Pro, Enterprise, or Education) with WSL 2
   - After installation, ensure Docker is running (check system tray)

2. **Minikube** (Required)
   - Option A - Direct Download:
     ```powershell
     # Download installer
     New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
     Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
     # Add to PATH
     $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
     if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
       [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
     }
     ```
   
   - Option B - Using Chocolatey:
     ```powershell
     choco install minikube
     ```

3. **kubectl** (Required)
   - Option A - Direct Download:
     ```powershell
     # Download kubectl
     cd ~
     mkdir .kube
     cd .kube
     curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
     # Add to PATH
     $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
     $newPath = "$oldPath;$HOME\.kube"
     [Environment]::SetEnvironmentVariable('Path', $newPath, [EnvironmentVariableTarget]::User)
     ```
   
   - Option B - Using Chocolatey:
     ```powershell
     choco install kubernetes-cli
     ```

4. **Helm** (Optional - for Prometheus)
   - Option A - Direct Download:
     ```powershell
     # Download and install
     choco install kubernetes-helm
     ```
   
   - Option B - Manual:
     - Download from: https://github.com/helm/helm/releases
     - Extract to C:\helm
     - Add C:\helm to PATH

### Optional Tools

5. **Chocolatey Package Manager** (Recommended)
   ```powershell
   # Run PowerShell as Administrator
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

6. **Git for Windows**
   ```powershell
   choco install git
   ```

7. **Windows Terminal** (Better than PowerShell)
   - Install from Microsoft Store
   - Or: `choco install microsoft-windows-terminal`

### Verification

After installing, verify everything works:

```powershell
# Check Docker
docker --version
docker ps

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Helm (optional)
helm version
```

## 🚀 Quick Start

### Step 1: Extract the Project

```powershell
# Navigate to your projects folder
cd C:\Users\YourName\Documents\Projects

# Extract the archive
# (Use Windows Explorer or 7-Zip if tar isn't available)
tar -xzf k8s-golang-demo.tar.gz
cd k8s-golang-demo
```

### Step 2: Deploy to Minikube

```powershell
# Open PowerShell as Administrator
# Navigate to project directory
cd C:\Users\YourName\Documents\Projects\k8s-golang-demo

# Run setup script
.\setup.ps1
```

**What the script does:**
- ✅ Checks prerequisites
- ✅ Starts Minikube
- ✅ Enables Ingress and metrics addons
- ✅ Builds Docker image
- ✅ Deploys application to Kubernetes
- ✅ Waits for pods to be ready

### Step 3: Configure Access

**Option A: Using Ingress (Recommended)**

Run PowerShell as Administrator:
```powershell
# Get minikube IP
$minikubeIP = minikube ip

# Add to hosts file
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "$minikubeIP data-api.local"

# Test it
curl http://data-api.local/health
```

**Option B: Using Port-Forward**

```powershell
# Start port-forward (run in separate terminal)
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80

# Test it (in another terminal)
curl http://localhost:8080/health
```

### Step 4: Test the API

```powershell
# Run test script
.\test.ps1 http://data-api.local

# Or test manually
curl http://data-api.local/health
curl http://data-api.local/ready

# Ingest data
$body = @{
    source = "windows-test"
    metrics = @{
        temperature = 23.5
        humidity = 65
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://data-api.local/ingest" -Method Post -ContentType "application/json" -Body $body

# Get data
curl http://data-api.local/data
```

## 📊 Setting Up Monitoring (Optional)

### Install Prometheus and Grafana

```powershell
# Run setup script
.\setup-prometheus.ps1

# Wait for installation to complete (2-3 minutes)
```

### Access Dashboards

**Prometheus:**
```powershell
# Start port-forward (keep terminal open)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open browser: http://localhost:9090
```

**Grafana:**
```powershell
# Start port-forward (keep terminal open)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open browser: http://localhost:3000
# Login: admin / prom-operator
```

## 🔍 Useful Commands

### Minikube

```powershell
# Start cluster
minikube start

# Stop cluster
minikube stop

# Delete cluster
minikube delete

# Get cluster IP
minikube ip

# Open dashboard
minikube dashboard

# SSH into cluster
minikube ssh

# View addons
minikube addons list
```

### Kubectl

```powershell
# View pods
kubectl get pods -n data-ingestion

# View logs
kubectl logs -n data-ingestion -l app=data-ingestion-api --tail=50

# Follow logs
kubectl logs -n data-ingestion -l app=data-ingestion-api -f

# Describe pod
kubectl describe pod <pod-name> -n data-ingestion

# View all resources
kubectl get all -n data-ingestion

# Port-forward
kubectl port-forward -n data-ingestion svc/data-ingestion-api 8080:80
```

### Docker (in Minikube context)

```powershell
# Set Docker to use Minikube
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# View images
docker images

# Build new image
docker build -t data-ingestion-api:latest .
```

## 🛠️ Troubleshooting Windows-Specific Issues

### Issue 1: PowerShell Execution Policy

**Error:** "cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 2: Docker Not Running

**Error:** "Cannot connect to Docker daemon"

**Solution:**
1. Open Docker Desktop from Start Menu
2. Wait for Docker to fully start (whale icon in system tray)
3. Run `docker ps` to verify

### Issue 3: Minikube Won't Start with Hyper-V

**Error:** "Unable to start VM"

**Solution:**
```powershell
# Use Docker driver instead
minikube start --driver=docker

# Or enable Hyper-V (requires restart)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### Issue 4: WSL 2 Issues

**Error:** WSL 2 installation incomplete

**Solution:**
```powershell
# Install WSL 2
wsl --install
wsl --set-default-version 2

# Restart computer
```

### Issue 5: Port Already in Use

**Error:** "bind: address already in use"

**Solution:**
```powershell
# Find process using port
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F

# Or use different port
kubectl port-forward -n data-ingestion svc/data-ingestion-api 9090:80
```

### Issue 6: Curl Not Available

**Error:** "curl : The term 'curl' is not recognized"

**Solution:**
```powershell
# Use Invoke-WebRequest instead
Invoke-WebRequest -Uri http://data-api.local/health

# Or use alias
curl http://data-api.local/health

# Or install curl
choco install curl
```

### Issue 7: Hosts File Permission Denied

**Error:** "Access denied" when editing hosts

**Solution:**
```powershell
# Run PowerShell as Administrator
# Then run the command
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "$(minikube ip) data-api.local"

# Or edit manually with Notepad as Admin
notepad C:\Windows\System32\drivers\etc\hosts
```

## 📂 Working with Files on Windows

### Editing Files

Use any of these editors:
- **VS Code**: `code .`
- **Notepad++**: Download from https://notepad-plus-plus.org/
- **Vim**: `choco install vim`
- **Notepad**: Built-in (basic)

### Line Endings

Git will handle line endings automatically, but to be safe:

```powershell
# Configure Git
git config --global core.autocrlf true
```

## 🧹 Cleanup

### Remove Everything

```powershell
# Run teardown
.\teardown.ps1

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Remove hosts entry (run as Admin)
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$content = Get-Content $hostsFile
$content | Where-Object { $_ -notmatch "data-api.local" } | Set-Content $hostsFile
```

## 🎓 Next Steps

1. **Explore the code**
   - Open `main.go` in VS Code
   - Modify the API endpoints
   - Add new features

2. **Learn Kubernetes**
   - Read `LEARNING_RESOURCES.md`
   - Complete Kubernetes tutorials
   - Experiment with kubectl commands

3. **Push to GitHub**
   ```powershell
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/k8s-golang-demo.git
   git push -u origin main
   ```

4. **Customize for portfolio**
   - Update README with your info
   - Add screenshots
   - Write blog post about it

## 💡 Windows Tips

### Use Windows Terminal
- Supports tabs and multiple shells
- Better than default PowerShell
- Install from Microsoft Store

### Enable WSL 2 for Better Performance
```powershell
wsl --install
wsl --set-default-version 2
```

### PowerShell Profile
Create shortcuts by editing your profile:
```powershell
notepad $PROFILE

# Add these lines:
function k { kubectl $args }
function mk { minikube $args }
Set-Alias -Name g -Value git
```

### Install Package Manager
```powershell
# Chocolatey makes installing tools easier
choco install -y git vscode golang kubernetes-cli kubernetes-helm
```

## 📚 Additional Resources

- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [Minikube Windows Guide](https://minikube.sigs.k8s.io/docs/drivers/docker/)
- [WSL 2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

## 🆘 Getting Help

If you're stuck:
1. Check `TROUBLESHOOTING.md` for common issues
2. View logs: `kubectl logs -n data-ingestion -l app=data-ingestion-api`
3. Check events: `kubectl get events -n data-ingestion`
4. Ask in Kubernetes Slack: https://kubernetes.slack.com/
