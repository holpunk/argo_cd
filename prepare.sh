#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Environment Preparation...${NC}"

# --- Prerequisites Check ---
echo "Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Error: docker is not installed.${NC}"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}Error: kubectl is not installed.${NC}"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo -e "${RED}Error: helm is not installed.${NC}"; exit 1; }

# --- Cluster Check ---
echo "Checking Kubernetes cluster connection..."
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}Error: Unable to connect to a Kubernetes cluster.${NC}"
    echo "Please ensure Docker Desktop (or your preferred cluster) is running."
    exit 1
fi
echo -e "${GREEN}Connected to Kubernetes cluster.${NC}"

# --- ArgoCD Installation ---
echo -e "\n${BLUE}--- Setting up ArgoCD ---${NC}"
if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "Creating 'argocd' namespace..."
    kubectl create namespace argocd
else
    echo "'argocd' namespace already exists."
fi

echo "Adding ArgoCD Helm repo..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

echo "Installing/Upgrading ArgoCD..."
helm upgrade --install argocd argo/argo-cd --namespace argocd --version 5.46.7 --wait

echo -e "${GREEN}ArgoCD installed.${NC}"

# --- Prometheus Installation ---
echo -e "\n${BLUE}--- Setting up Prometheus ---${NC}"
echo "Adding Prometheus Community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

echo "Installing/Upgrading Prometheus Stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace default --wait

echo -e "${GREEN}Prometheus installed.${NC}"

# --- Application Preparation ---
echo -e "\n${BLUE}--- Preparing Application ---${NC}"

# --- CONFIGURATION (CHANGE THESE) ---
IMAGE_NAME="aqshey/argo_cd:latest" # Change this to your dockerhub_username/repo:tag
# ------------------------------------

# Build Docker image
echo "Building Docker image '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" .

# Apply ServiceMonitor
echo "Applying ServiceMonitor..."
kubectl apply -f servicemonitor.yaml

# Apply ArgoCD Application
echo "Applying ArgoCD Application manifest..."
kubectl apply -f argocd-app.yaml

# Create Secret for Private Repo (if needed) - Placeholder
# kubectl create secret generic git-creds --from-literal=username=... --from-literal=password=... -n argocd --dry-run=client -o yaml | kubectl apply -f -

echo -e "\n${GREEN}Environment preparation complete!${NC}"
echo -e "You can now verify the deployment with:\n  kubectl get applications -n argocd"
echo -e "Or use './connect.sh' to access the services."
