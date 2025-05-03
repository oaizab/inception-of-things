#!/bin/bash

# Colors for echo messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}Starting setup process...${NC}"

echo -e "${YELLOW}K3d cluster creation...${NC}"
k3d cluster create p3

echo -e "${YELLOW}Creating namespace...${NC}"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "${YELLOW}Installing ArgoCD...${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${GREEN}Setup completed successfully!${NC}"

"${SCRIPT_DIR}/launch.sh" "call from setup.sh"
