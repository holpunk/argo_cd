#!/bin/bash
# Session Command Log
# This file contains the commands executed during this session to set up, debug, and access the environment.

# --- Setup & Installation ---
brew install helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack

# --- Application Build & Deploy ---
# Rebuilding the Docker image after code changes
docker build -t aqshey/argo_cd:latest .
# Deploying/Upgrading the Flask application via Helm
helm upgrade --install flask-app ./flask-chart

# --- Verification & Debugging ---
# Checking Status
kubectl get pods
kubectl get svc
kubectl get servicemonitors --all-namespaces

# Checking Logs
kubectl logs -l app.kubernetes.io/instance=flask-app

# Testing Connectivity & Metrics
curl -v http://localhost:80/metrics
# Executing into the pod for internal verification
kubectl exec -it deployment/flask-app-flask-api -- cat main.py
kubectl exec -it deployment/flask-app-flask-api -- pip list
kubectl exec -it deployment/flask-app-flask-api -- curl -v http://localhost:5000/metrics

# --- ServiceMonitor Configuration ---
# Applying the ServiceMonitor to enable Prometheus scraping
kubectl apply -f servicemonitor.yaml

# --- Credentials Retrieval ---
# Grafana Admin Password
kubectl get secret --namespace default prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d

# ArgoCD Admin Password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# --- Port Forwarding (Manual Reference) ---
# Note: The ./connect.sh script automates this.
# Grafana
# kubectl port-forward svc/prometheus-grafana 3000:80
# Prometheus
# kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
# Flask App
# kubectl port-forward svc/flask-app-flask-api 8080:80
# ArgoCD
# kubectl port-forward svc/argocd-server -n argocd 8081:80
