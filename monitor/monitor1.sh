#!/bin/bash
set -e  # Exit immediately if any command fails

echo "=== Setting up monitoring stack ==="

# Create monitoring namespace if it doesn't exist
kubectl get namespace monitoring >/dev/null 2>&1 || \
kubectl create namespace monitoring

# Add Helm repos if not already added
if ! helm repo list | grep -q prometheus-community; then
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi
if ! helm repo list | grep -q grafana; then
  helm repo add grafana https://grafana.github.io/helm-charts
fi
helm repo update

echo "--- Installing Prometheus ---"
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set server.persistentVolume.enabled=false \
  --set alertmanager.persistentVolume.enabled=false \
  --wait

echo "--- Installing Grafana ---"
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set adminPassword=admin \
  --set service.type=LoadBalancer \
  --wait

echo "=== Monitoring components installed ==="

# Get Grafana URL
echo "Waiting for Grafana service to be ready..."
sleep 10  # Give some time for the LoadBalancer to be provisioned

GRAFANA_URL=$(minikube service grafana -n monitoring --url 2>/dev/null || true)

if [ -n "$GRAFANA_URL" ]; then
  echo "Grafana Dashboard: $GRAFANA_URL"
  echo "Username: admin"
  echo "Password: admin"
else
  echo "Could not determine Grafana URL. You can access it using port-forwarding:"
  echo "  kubectl port-forward -n monitoring service/grafana 3000:80"
  echo "Then open http://localhost:3000 in your browser"
fi

# Verify pods are running
echo ""
echo "Verifying pods status..."
kubectl get pods -n monitoring -o wide

echo ""
echo "=== Monitoring deployment complete ==="