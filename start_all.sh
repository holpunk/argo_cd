#!/bin/bash
# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting up environment...${NC}"

# 1. Start Docker if not running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Starting Docker Desktop..."
    open -a Docker
    echo "Waiting for Docker to initialize..."
    # Wait loop
    while ! docker info > /dev/null 2>&1; do
        sleep 5
        echo -n "."
    done
    echo -e "\n${GREEN}Docker is ready!${NC}"
else
    echo "Docker is already running."
fi

# 2. Install Prometheus Stack
echo "Checking Prometheus..."
if ! helm status prometheus > /dev/null 2>&1; then
    echo "Installing Prometheus Stack (this may take a minute)..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/kube-prometheus-stack
else
    echo "Prometheus is already installed."
fi

# 3. Build & Deploy Flask App
echo "Building Flask App Docker Image..."
docker build -t aqshey/argo_cd:latest .

echo "Deploying Flask App via Helm..."
helm upgrade --install flask-app ./flask-chart

# 4. Apply ServiceMonitor
echo "Configuring Prometheus Scraping..."
# Retry loop for ServiceMonitor in case CRDs are still creating
for i in {1..10}; do
    if kubectl apply -f servicemonitor.yaml; then
        break
    fi
    echo "Waiting for ServiceMonitor CRD..."
    sleep 5
done

echo -e "${GREEN}All services started!${NC}"
echo "Run './connect.sh' to access the application and dashboards."
