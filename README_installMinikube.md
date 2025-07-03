The issue is clear: your `kubectl` is configured to connect to an AWS EKS cluster (`grp-4-eks-cluster`), but you need to set up Minikube for local development. Here's how to properly configure your local environment:

## Step 1: Install and Set Up Minikube

### 1. First install Minikube (if not already installed):
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. Start Minikube with adequate resources:
```bash
minikube start --driver=docker --memory=4096 --cpus=2
```

### 3. Verify Minikube cluster:
```bash
minikube status
```

## Step 2: Configure kubectl for Minikube

### 1. Get Minikube context:
```bash
minikube update-context
```

### 2. Verify available contexts:
```bash
kubectl config get-contexts
```
You should now see both your EKS and Minikube contexts.

### 3. Switch to Minikube context:
```bash
kubectl config use-context minikube
```

## Step 3: Verify Local Cluster Access

```bash
kubectl get nodes
```
Should show a single Minikube node (not AWS nodes).

## Step 4: Apply Your Manifests Locally

Now you can safely apply your manifests:
```bash
kubectl apply -f manifests/
```

## Important Notes

1. **AWS vs Local**:
   - Your EKS configuration remains intact in `~/.kube/config`
   - You're just switching contexts for local work

2. **Context Switching**:
   ```bash
   # Switch to AWS EKS
   kubectl config use-context arn:aws:eks:us-east-1:255945442255:cluster/grp-4-eks-cluster
   
   # Switch back to Minikube
   kubectl config use-context minikube
   ```

3. **Troubleshooting**:
   If Minikube doesn't appear in contexts:
   ```bash
   minikube delete
   minikube start
   minikube update-context
   ```

Would you like me to explain how to manage multiple clusters more efficiently (e.g., using aliases or tools like `kubectx`)? This can make switching between AWS and local clusters much easier.
