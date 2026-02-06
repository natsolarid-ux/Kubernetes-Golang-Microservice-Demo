# Learning Resources for DevOps/SRE/Platform Engineering

## 🚀 Quick Start (Days, Not Months)

### Week 1: Kubernetes Basics
- **Day 1-2**: Install tools (minikube, kubectl, kind)
- **Day 3-4**: Complete [Kubernetes Basics Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- **Day 5-7**: Deploy this project and experiment with it

### Week 2: Golang Fundamentals
- **Day 1-3**: Complete [Tour of Go](https://tour.golang.org/)
- **Day 4-5**: [Go by Example](https://gobyexample.com/) - HTTP servers section
- **Day 6-7**: Modify this project's API, add new endpoints

### Week 3-4: Advanced Topics
- Prometheus monitoring and alerting
- CI/CD with GitHub Actions
- Infrastructure as Code (Terraform basics)
- Troubleshooting techniques

## 📚 Free Resources

### Kubernetes

#### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

#### Interactive Learning
- [Katacoda Kubernetes Scenarios](https://www.katacoda.com/courses/kubernetes) - Browser-based labs
- [Play with Kubernetes](https://labs.play-with-k8s.com/) - Free 4-hour sessions
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Deep dive

#### CKAD Preparation (FREE)
- [CKAD Exercises by dgkanatsios](https://github.com/dgkanatsios/CKAD-exercises)
- [CKAD Resources](https://github.com/lucassha/CKAD-resources)
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Allowed during exam

#### Books (Library/Safari)
- "Kubernetes in Action" by Marko Lukša
- "Kubernetes Up & Running" by Kelsey Hightower
- "The Kubernetes Book" by Nigel Poulton

### Golang

#### Official Resources
- [A Tour of Go](https://tour.golang.org/) - Interactive tutorial
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://golang.org/doc/effective_go)
- [Go Documentation](https://golang.org/doc/)

#### Free Courses
- [freeCodeCamp Go Course](https://www.youtube.com/watch?v=YS4e4q9oBaU) - 7 hour video
- [Go Track on Exercism](https://exercism.org/tracks/go) - Practice exercises with mentoring

#### Books
- "The Go Programming Language" by Donovan & Kernighan
- "Learning Go" by Jon Bodner

### Docker

- [Docker Official Tutorial](https://docs.docker.com/get-started/)
- [Docker for Beginners](https://docker-curriculum.com/)
- [Play with Docker](https://labs.play-with-docker.com/)

### Prometheus & Monitoring

- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [PromQL for Beginners](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Tutorials](https://grafana.com/tutorials/)

## 🛠️ Local Development Tools

### Essential (Install These)

```bash
# Minikube - Local Kubernetes
brew install minikube  # macOS
# or download from: https://minikube.sigs.k8s.io/docs/start/

# kubectl - Kubernetes CLI
brew install kubectl  # macOS
# or: https://kubernetes.io/docs/tasks/tools/

# Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# k9s - Terminal UI for K8s (optional but recommended)
brew install k9s  # macOS
```

### Alternative to Minikube

```bash
# kind (Kubernetes in Docker) - faster than minikube
brew install kind
# or: https://kind.sigs.k8s.io/docs/user/quick-start/

# Create cluster
kind create cluster --name demo

# Use this project with kind by changing eval line in setup.sh
# Instead of: eval $(minikube docker-env)
# Use: docker build ... and then load into kind:
# kind load docker-image data-ingestion-api:latest --name demo
```

### Productivity Tools

- **k9s**: Terminal UI for Kubernetes - `brew install k9s`
- **kubectx/kubens**: Switch contexts and namespaces easily
- **stern**: Multi-pod log tailing - `brew install stern`
- **helm**: Package manager for Kubernetes
- **jq**: JSON processor - `brew install jq`

## 📖 Learning Path for Career Transition

### Foundation (2-4 weeks)

1. **Linux/Unix Basics** (if needed)
   - Command line navigation
   - File permissions
   - Process management
   - Shell scripting basics

2. **Docker Fundamentals**
   - Container concepts
   - Dockerfile creation
   - Image building and optimization
   - Docker Compose

3. **Kubernetes Basics**
   - Pods, Deployments, Services
   - ConfigMaps and Secrets
   - Basic kubectl commands
   - Deploy this demo project

### Intermediate (4-8 weeks)

4. **Kubernetes Deep Dive**
   - StatefulSets, DaemonSets
   - Persistent Volumes
   - RBAC and Security
   - Ingress and networking
   - Resource management

5. **Golang for DevOps**
   - HTTP servers and clients
   - Working with JSON APIs
   - Error handling
   - Testing and benchmarking
   - Building CLI tools

6. **Observability**
   - Prometheus metrics
   - Grafana dashboards
   - Log aggregation (ELK/Loki)
   - Distributed tracing (Jaeger)

### Advanced (8-12 weeks)

7. **CI/CD**
   - GitHub Actions
   - GitLab CI
   - ArgoCD (GitOps)
   - Jenkins (if required)

8. **Infrastructure as Code**
   - Terraform basics
   - Pulumi (optional)
   - Helm charts

9. **Cloud Platforms** (pick one)
   - AWS (EKS, EC2, S3, RDS)
   - GCP (GKE, Compute, Storage)
   - Azure (AKS)

## 🎯 Certification Path (Optional)

### Kubernetes
- **CKA** (Certified Kubernetes Administrator) - ~$395
- **CKAD** (Certified Kubernetes Application Developer) - ~$395
- **CKS** (Certified Kubernetes Security Specialist) - ~$395

### Cloud
- **AWS Certified Solutions Architect**
- **Google Cloud Associate Engineer**
- **Azure Administrator**

### Tips
- Not required but helpful for resume
- Focus on hands-on experience first
- Certifications are proof of baseline knowledge
- Many employers will pay for certifications

## 💼 Building Your Portfolio

### What to Include

1. **This Demo Project** (foundational)
   - Shows Kubernetes, Docker, Go, monitoring basics

2. **CI/CD Pipeline Project**
   - GitHub Actions workflow
   - Automated testing
   - Container registry push
   - Automated deployment

3. **Infrastructure as Code Project**
   - Terraform for AWS/GCP/Azure
   - Multi-environment setup
   - State management

4. **Monitoring/Observability Project**
   - Custom Grafana dashboards
   - Alert rules in Prometheus
   - Log aggregation setup

5. **Automation Tool**
   - Golang CLI tool
   - Solves a real problem
   - Well-documented

### GitHub Profile Tips

- Pin your best 6 projects
- Professional README for each
- Consistent commit history
- Clear documentation
- Include architecture diagrams
- Add badges (build status, coverage)

## 🔧 Shell Scripting Skills (From Your Background)

You mentioned Linux exposure - emphasize these skills:

### Transferable Skills
- **Automation**: Convert manual operations into scripts
- **System Administration**: Understanding of processes, files, networking
- **Debugging**: Reading logs, troubleshooting issues
- **Documentation**: Writing runbooks and procedures

### Level Up Your Bash
```bash
# Error handling
set -euo pipefail

# Functions and modularity
function deploy() {
    local env=$1
    echo "Deploying to ${env}"
}

# Argument parsing
while getopts "e:r:h" opt; do
    case $opt in
        e) environment=$OPTARG ;;
        r) region=$OPTARG ;;
        h) show_help; exit 0 ;;
    esac
done
```

### Python for DevOps (Alternative to Bash)
- Great for complex logic
- Rich ecosystem (boto3 for AWS, kubernetes client)
- Better error handling than bash

## 📈 Interview Preparation

### Topics to Study

1. **Kubernetes Concepts**
   - Pod lifecycle and scheduling
   - Service types and networking
   - ConfigMaps vs Secrets
   - RBAC concepts
   - Resource requests/limits

2. **Docker**
   - Image layering and caching
   - Multi-stage builds
   - Security best practices
   - Networking modes

3. **System Design**
   - High availability patterns
   - Load balancing
   - Caching strategies
   - Microservices architecture

4. **Troubleshooting**
   - Pod not starting (ImagePullBackOff, CrashLoopBackOff)
   - Service not accessible
   - Performance issues
   - Resource exhaustion

### Practice Problems

- Deploy a complex app (DB + backend + frontend)
- Set up monitoring and alerting
- Implement blue-green deployment
- Configure auto-scaling
- Troubleshoot common issues

## 🎓 Weekly Study Plan

### Week 1: Foundations
- Mon-Tue: Minikube setup + K8s basics tutorial
- Wed-Thu: Deploy this demo project
- Fri: Explore with kubectl, k9s
- Weekend: Modify the Go code, add features

### Week 2: Deep Dive
- Mon-Wed: Kubernetes networking (Services, Ingress)
- Thu-Fri: RBAC and security
- Weekend: Create second project

### Week 3: Monitoring
- Mon-Tue: Prometheus setup and queries
- Wed-Thu: Grafana dashboards
- Fri: Alerting rules
- Weekend: Add custom metrics to app

### Week 4: Automation
- Mon-Wed: Bash scripting practice
- Thu-Fri: GitHub Actions basics
- Weekend: Add CI/CD to demo project

## 🚀 Next Steps

1. **Complete this demo project**
   - Deploy it successfully
   - Test all endpoints
   - Set up Prometheus monitoring
   - Add your own feature

2. **Create GitHub repository**
   - Push code with clear commits
   - Write detailed README
   - Add screenshots/diagrams

3. **Share and document**
   - LinkedIn post with demo
   - Blog post about learnings
   - Twitter thread (optional)

4. **Iterate and expand**
   - Add CI/CD pipeline
   - Deploy to cloud (EKS/GKE)
   - Add more features

## 📚 Recommended Free Courses

### Kubernetes
- [Kubernetes for Beginners - KodeKloud](https://kodekloud.com/courses/kubernetes-for-the-absolute-beginners-hands-on/)
- [Kubernetes Learning Path - Microsoft Learn](https://docs.microsoft.com/en-us/learn/paths/intro-to-kubernetes-on-azure/)

### DevOps
- [DevOps Prerequisites Course - freeCodeCamp](https://www.youtube.com/watch?v=Wvf0mBNGjXY)
- [Linux for DevOps - freeCodeCamp](https://www.youtube.com/watch?v=BHVR_5MTQAA)

### Cloud
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Google Cloud Free Tier](https://cloud.google.com/free)

Remember: **Hands-on practice beats theory every time.** Build projects, break things, fix them, and document your journey!
