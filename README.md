# Flask App with Prometheus & ArgoCD

This project demonstrates a basic implementation of a Flask application instrumented with Prometheus metrics, deployed on a local Kubernetes cluster. It includes automation scripts for easy setup and a Helm chart for deployment.

## Project Structure

- **`main.py`**: A simple Flask application with:
  - `/items` (GET/POST): Sample API endpoints.
  - `/metrics`: Prometheus metrics endpoint.
- **`flask-chart/`**: Helm chart for deploying the Flask application.
- **`argocd-app.yaml`**: ArgoCD Application manifest (for GitOps-style deployment).
- **`start_all.sh`**: Automation script to provision the environment (Prometheus, Docker build, Helm install).
- **`connect.sh`**: Helper script to port-forward services (Grafana, ArgoCD, Prometheus, Flask App) and retrieve passwords.

## Prerequisites

Ensure you have the following installed on your local machine:
1.  **Docker Desktop** (with Kubernetes enabled) OR Minikube/Kind.
2.  **Helm** (`brew install helm`).
3.  **Kubectl** (`brew install kubectl`).
4.  **ArgoCD CLI** (optional, for managing ArgoCD).

## Quick Start (Local Deployment)

This project includes scripts to automate the deployment process on a local Kubernetes cluster.

### 1. Start the Environment
Run the start script to check for Docker, install the Prometheus stack, build the local image, and deploy the application.

```bash
chmod +x start_all.sh
./start_all.sh
```

### 2. Access the Application
Once the deployment is complete, run the connection script to set up port-forwarding and retrieve login credentials for Grafana and ArgoCD.

```bash
chmod +x connect.sh
./connect.sh
```

This will output the URLs and credentials for:
- **Grafana**: `http://localhost:3000` (User: `admin`)
- **ArgoCD**: `http://localhost:8081` (User: `admin`)
- **Prometheus**: `http://localhost:9090`
- **Flask App**: `http://localhost:8080`

## Manual Deployment Steps

If you prefer to run steps manually or need to debug:

1.  **Install Prometheus Stack**:
    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm install prometheus prometheus-community/kube-prometheus-stack
    ```

2.  **Build Docker Image**:
    ```bash
    docker build -t aqshey/argo_cd:latest .
    ```

3.  **Deploy Flask App**:
    ```bash
    helm upgrade --install flask-app ./flask-chart
    ```

4.  **Apply ServiceMonitor** (for Prometheus scraping):
    ```bash
    kubectl apply -f servicemonitor.yaml
    ```

## GitOps with ArgoCD

An `argocd-app.yaml` is provided for GitOps deployment. To use it:

1.  Ensure you have pushed your latest changes to the remote repository (`https://github.com/holpunk/argo_cd.git`).
2.  Apply the content:
    ```bash
    kubectl apply -f argocd-app.yaml
    ```
3.  ArgoCD will attempt to sync the state from the Git repository.

## Current Limitations

-   **Local Image**: The Helm chart pulls `image: aqshey/argo_cd:latest`. This works locally with Docker Desktop if `imagePullPolicy` is set correctly (defaulting to `IfNotPresent` usually works if the image exists locally).
-   **ServiceMonitor Labels**: Ensure the `serviceMonitor.yaml` selector matches the labels in your Helm chart's Service definition.
