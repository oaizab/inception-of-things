#!/bin/bash

# Colors for echo messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$PROJECT_ROOT")"

echo -e "${BLUE}Launching application...${NC}"

if [ "$1" ]; then
    sleep 10
fi

echo -e "${YELLOW}ArgoCD setup...${NC}"

echo -e "${YELLOW}Waiting for ArgoCD pods to be ready...${NC}"

kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s

echo -e "${YELLOW}ArgoCD setup completed successfully!${NC}" 

# Kill any existing port-forward processes
echo -e "${YELLOW}Cleaning up existing port forwards...${NC}"
kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null

# Start new port forwarding
echo -e "${YELLOW}Setting up new port forwarding...${NC}"
kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null &

# Wait for port-forward to be ready
sleep 3

ARGO_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "${YELLOW}ArgoCD password: ${ARGO_PASSWORD}${NC}"

# Login to ArgoCD
echo -e "${YELLOW}Logging in to ArgoCD...${NC}"
argocd login localhost:9393 --username admin --password $ARGO_PASSWORD --insecure --grpc-web

kubectl config set-context --current --namespace=argocd

# Create ArgoCD application
echo -e "${YELLOW}Creating ArgoCD application...${NC}"
argocd app create will-app \
    --repo https://github.com/oaizab/inception-of-things.git \
    --path p3/confs \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev \
    --sync-policy automated

# Check if app creation failed because it already exists
if [ $? -eq 20 ]; then
    echo -e "${RED}An error occurred when creating ArgoCD app 'will-app'."
    echo -e "Probably because the ArgoCD app 'will-app' already exists.${NC}"
    read -p 'Do you want us to delete and recreate the app? (y/n): ' input
    if [ "$input" = 'y' ]; then
        echo -e "${YELLOW}Deleting existing app...${NC}"
        yes | argocd app delete will-app --grpc-web &>/dev/null
        echo -e "${YELLOW}Recreating ArgoCD app...${NC}"
        argocd app create will-app \
            --repo https://github.com/oaizab/inception-of-things.git \
            --path p3/confs \
            --dest-server https://kubernetes.default.svc \
            --dest-namespace dev \
            --sync-policy automated
    else
        echo -e "${RED}Operation cancelled. Exiting...${NC}"
        exit 1
    fi
fi

echo -e "${CYAN}View created app before sync and configuration${NC}"
argocd app get will-app --grpc-web
sleep 5

echo -e "${CYAN}Sync the app and configure for automated synchronization${NC}"
argocd app sync will-app --grpc-web
sleep 5

echo -e "${YELLOW}Setting automated sync policy${NC}"
argocd app set will-app --sync-policy automated --grpc-web
sleep 5

echo -e "${YELLOW}Setting auto-prune policy${NC}"
argocd app set will-app --auto-prune --allow-empty --grpc-web
sleep 5

echo -e "${CYAN}View created app after sync and configuration${NC}"
argocd app get will-app --grpc-web

# Wait for application to be created and synced
echo -e "${YELLOW}Waiting for application to sync...${NC}"
argocd app wait will-app --timeout 120

echo -e "${GREEN}Application launched successfully!${NC}" 