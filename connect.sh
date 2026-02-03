#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Retrieving credentials and setting up connections...${NC}"

# Get Grafana Password
GRAFANA_PASSWORD=$(kubectl get secret --namespace default prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d)

# Get ArgoCD Password
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

echo -e "\n${GREEN}=== Access Information ===${NC}"
echo -e "${YELLOW}Grafana:${NC}    http://localhost:3000"
echo -e "${YELLOW}User/Pass:${NC}  admin / $GRAFANA_PASSWORD"
echo -e "--------------------------"
echo -e "${YELLOW}ArgoCD:${NC}     http://localhost:8081"
echo -e "${YELLOW}User/Pass:${NC}  admin / $ARGOCD_PASSWORD"
echo -e "--------------------------"
echo -e "${YELLOW}Prometheus:${NC} http://localhost:9090"
echo -e "${YELLOW}Flask API:${NC}  http://localhost:8080"
echo -e "${YELLOW}Metrics:${NC}    http://localhost:8080/metrics"
echo -e "=========================="

echo -e "\n${BLUE}Starting Port Forwarding...${NC}"
echo "(Press Ctrl+C to stop all connections)"

# Function to kill background processes on exit
cleanup() {
    echo -e "\n${BLUE}Stopping all port-forwards...${NC}"
    kill $(jobs -p) 2>/dev/null
    exit
}
trap cleanup SIGINT

# Start Port Forwarding in background
kubectl port-forward svc/prometheus-grafana 3000:80 > /dev/null 2>&1 &
PID1=$!
echo "Forwarding Grafana (port 3000)..."

kubectl port-forward svc/argocd-server -n argocd 8081:80 > /dev/null 2>&1 &
PID2=$!
echo "Forwarding ArgoCD (port 8081)..."

kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 > /dev/null 2>&1 &
PID3=$!
echo "Forwarding Prometheus (port 9090)..."

kubectl port-forward svc/flask-app-flask-api 8080:80 > /dev/null 2>&1 &
PID4=$!
echo "Forwarding Flask API (port 8080)..."

# Keep script running
wait
