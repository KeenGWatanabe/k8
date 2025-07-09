branch : Monitor
# launch : deploy.sh (shell script quick launch)
![deployed image](/images/deployed.png)

# deploy : .github/workflows/deploy.yaml (CICD)
![CI/CD](/images/CICD.png)

This deployment is purely local [minikube](./README_files/README_minikube.md)only. [install_minikube](./README_files/README_installMinikube.md)
AWS k8 deployment is another repo [costing](./README_files/README_costing.md)

### App repo #########################

startup Docker desktop (Windows)

(Linux)
sudo systemctl start docker 

# Use Docker Hub

docker login -u rger
# Tag and Push to Docker Hub:
docker tag taskmgr-pte-repo:latest rger/taskmgr-pte-repo:latest
docker push rger/taskmgr-pte-repo:latest

### App repo #########################

# Option 1- Use shellscript to run it 


Start Docker Desktop with 'Github acct' (Windows)
```bash
sudo systemctl start docker (Linux)
docker login -u rger
```


# run deploy.sh (script for below sequence)
```bash
chmod +x deploy.sh
./deploy.sh
```

# run monitor.sh (script for Grafana+Prometheus)
[GrafanaPrometheus](./README_files/README_GrafanaPrometheus.md)
[HelmCharts](./README_files/README_Helmfinal.md)
[helm_monitor](./README_files/README_helm_monitor_sh.md)
```bash
chmod +x monitor/monitor.sh
./monitor/monitor.sh
```

![Grafana](/images/Grafana.png)

# Option 2-Run it manually below

1. **Start Minikube**:
   ```bash
   minikube start --driver=docker
   minikube addons enable ingress
   ```

2. **Deploy to Minikube**:
   ```bash
   kubectl delete -f manifests/  # Clean up existing (optional)

# Apply dependencies first
kubectl apply -f manifests/configmap.yaml

kubectl apply -f manifests/app-secrets.yaml

kubectl apply -f manifests/mongo-db.yaml

# Wait for MongoDB to be ready
kubectl wait --for=condition=Ready pod -l app=mongo --timeout=120s

# Then apply deployment
kubectl apply -f manifests/deployment.yaml

# Wait for pods to initialize
kubectl wait --for=condition=Available deployment/app-deployment --timeout=180s

# ClusterIP / NodePort
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml

# Verify Deployment  
kubectl get all

3. **Access Your App**:
   ```bash
   minikube service nodeapp-service
   # OR for ingress:S
   minikube tunnel
   curl http://localhost
   ```
# check status
kubectl get pods,svc,ingress

## 🔍 Verification Checklist
1. Pods running:
   ```bash
   kubectl get pods
   ```
2. Service exposed:
   ```bash
   kubectl get svc
   ```
3. Ingress routes (if used):
   ```bash
   kubectl get ingress
   ```
4. Stop deployment or Cleanup
    [Cleanup](./README_files/README_stopDeployments.md)

## 📌 Key Recommendations
1. **Add service.yaml** - Critical for accessibility
2. **Consider namespaces** - Add `metadata.namespace` to resources
3. **Add health checks** - Liveness/readiness probes in deployment





