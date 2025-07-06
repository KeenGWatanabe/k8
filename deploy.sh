#!/bin/bash

# Start Minikube
minikube start --driver=docker
minikube addons enable ingress

# Deploy manifests in order
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/app-secrets.yaml
kubectl apply -f manifests/mongo-db.yaml

# Wait for MongoDB
kubectl wait --for=condition=Ready pod -l app=mongo --timeout=120s

# Deploy the app
kubectl apply -f manifests/deployment.yaml
kubectl wait --for=condition=Available deployment/app-deployment --timeout=180s

# Expose the app
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml

# Print access info
echo "=== Access Instructions ==="
echo "1. Run in another terminal: minikube tunnel"
echo "2. Access via: http://localhost"
echo "3. OR use direct service URL:"
minikube service nodeapp-service --url