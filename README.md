startup Docker desktop (Windows) 

# Use Docker Hub
docker login -u rger
# Tag and Push to Docker Hub:
docker tag taskmgr-pte-repo:latest rger/taskmgr-pte-repo:latest
docker push rger/taskmgr-pte-repo:latest

1. **Start Minikube**:
   ```bash
   minikube start --driver=docker
   minikube addons enable ingress
   ```

2. **Deploy to Minikube**:
   ```bash
   kubectl apply -f manifests/
   ```

3. **Access Your App**:
   ```bash
   minikube service nodeapp-service
   # OR for ingress:
   minikube tunnel
   curl http://localhost
   ```

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

## 📌 Key Recommendations
1. **Add service.yaml** - Critical for accessibility
2. **Consider namespaces** - Add `metadata.namespace` to resources
3. **Add health checks** - Liveness/readiness probes in deployment


