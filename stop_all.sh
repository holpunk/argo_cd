#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Stopping services to save resources...${NC}"

# 1. Kill background port-forwards
echo "Stopping port forwarding..."
pkill -f "kubectl port-forward" || echo "No port forwards running."

# 2. Uninstall Helm Releases
echo "Uninstalling Flask App..."
helm uninstall flask-app 2>/dev/null || echo "Flask App not found."

echo "Uninstalling Prometheus Stack..."
helm uninstall prometheus 2>/dev/null || echo "Prometheus not found."

# 3. Clean up additional resources
kubectl delete servicemonitor flask-app-monitor 2>/dev/null

echo -e "${GREEN}Cluster resources cleaned up.${NC}"

# 4. Optional: Quit Docker Desktop
echo -e "${RED}Do you want to completely shutdown Docker Desktop? (y/n)${NC}"
read -t 10 -p "(Default: n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo -e "\nQuitting Docker Desktop..."
    osascript -e 'quit app "Docker"'
    echo "Docker Desktop stopped."
else
    echo -e "\nDocker Desktop left running."
fi
