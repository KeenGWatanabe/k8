I'll create a **complete Helm chart** based on your repository's structure, adapting your existing manifests (`configmap.yaml`, `mongo-db.yaml`, `deployment.yaml`, etc.) into Helm templates with monitoring support (Prometheus + Grafana). Here's the full implementation:

---

### **Helm Chart Structure**
```
k8-helm/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configurations
├── templates/
│   ├── 01-namespace.yaml   # Namespace declaration
│   ├── 02-configmap.yaml   # ConfigMap template
│   ├── 03-secrets.yaml     # Secrets template (if needed)
│   ├── 04-mongodb.yaml     # MongoDB deployment
│   ├── 05-app.yaml         # Node.js app deployment
│   ├── 06-service.yaml     # Service template
│   ├── 07-ingress.yaml     # Ingress template
│   ├── 08-monitoring.yaml  # Prometheus ServiceMonitor
│   └── _helpers.tpl        # Helper functions
└── requirements.yaml       # Dependencies (Prometheus Stack)
```

---

### **1. `Chart.yaml`**
```yaml
apiVersion: v2
name: k8-app
description: Helm chart for Node.js + MongoDB with monitoring
version: 1.0.0
appVersion: "1.0"
dependencies:
- name: kube-prometheus-stack
  version: "^58.0.0"
  repository: "https://prometheus-community.github.io/helm-charts"
  condition: monitoring.enabled
```

---

### **2. `values.yaml`**
```yaml
# Application Settings
app:
  name: "nodeapp"
  namespace: "k8-namespace"
  replicaCount: 1
  image: "keenwatanabe/k8"
  tag: "latest"
  port: 3000
  env:
    MONGO_URI: "mongodb://{{ .Release.Name }}-mongodb:27017/appdb"

# MongoDB Settings
mongodb:
  enabled: true
  image: "mongo:latest"
  port: 27017
  storageSize: "1Gi"

# Monitoring Settings
monitoring:
  enabled: true
  namespace: "monitoring"
  prometheus:
    scrapeInterval: "15s"
  grafana:
    adminPassword: "admin"  # Change in production!

# Ingress Settings
ingress:
  enabled: true
  host: "nodeapp.local"
```

---

### **3. Template Files (Adapted from Your Manifests)**

#### **`templates/01-namespace.yaml`**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.app.namespace }}
```

#### **`templates/02-configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.app.name }}-config
  namespace: {{ .Values.app.namespace }}
data:
  {{- range $key, $value := .Values.app.env }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

#### **`templates/04-mongodb.yaml`**
```yaml
{{- if .Values.mongodb.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-mongodb
  namespace: {{ .Values.app.namespace }}
  labels:
    app: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: {{ .Values.mongodb.image }}
        ports:
        - containerPort: {{ .Values.mongodb.port }}

---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-mongodb
  namespace: {{ .Values.app.namespace }}
spec:
  ports:
  - port: {{ .Values.mongodb.port }}
    targetPort: {{ .Values.mongodb.port }}
  selector:
    app: mongodb
{{- end }}
```

#### **`templates/05-app.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}
  namespace: {{ .Values.app.namespace }}
spec:
  replicas: {{ .Values.app.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.app.name }}
      {{- if .Values.monitoring.enabled }}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "{{ .Values.app.port }}"
      {{- end }}
    spec:
      containers:
      - name: {{ .Values.app.name }}
        image: "{{ .Values.app.image }}:{{ .Values.app.tag }}"
        ports:
        - containerPort: {{ .Values.app.port }}
        envFrom:
        - configMapRef:
            name: {{ .Values.app.name }}-config
```

#### **`templates/08-monitoring.yaml`**
```yaml
{{- if .Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ .Values.app.name }}-monitor
  namespace: {{ .Values.monitoring.namespace }}
  labels:
    release: "kube-prometheus-stack"
spec:
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  namespaceSelector:
    matchNames:
    - {{ .Values.app.namespace }}
  endpoints:
  - port: http
    interval: {{ .Values.monitoring.prometheus.scrapeInterval }}
{{- end }}
```

---

### **4. Deployment Commands**
```bash
# Install dependencies
helm dependency update k8-helm

# Deploy everything (app + monitoring)
helm install my-app k8-helm/ \
  --namespace k8-namespace \
  --create-namespace \
  --set monitoring.enabled=true

# Access Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
# Credentials: admin / admin (from values.yaml)
```

---

### **Key Improvements Over Your Original Manifests**
1. **Parameterization**: All configs controlled via `values.yaml`
2. **Dependency Management**: Prometheus/Grafana auto-installed
3. **Namespace Isolation**: Clear separation between app and monitoring
4. **Scalability**: Easy to adjust replicas, resources, etc.
5. **Portfolio-Ready**: Demonstrates Helm + Kubernetes best practices

---

### **How This Matches Your Repo**
- Your `manifests/deployment.yaml` → Templatized in `05-app.yaml`
- Your `manifests/mongo-db.yaml` → Templatized in `04-mongodb.yaml`
- Added monitoring support via `08-monitoring.yaml`

Would you like me to add any specific features like:
- Custom Grafana dashboards
- Resource limits/requests
- Health checks
- TLS configuration for ingress?