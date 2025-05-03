#!/bin/bash

# Colors for echo messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}Performing full clean...${NC}"

echo -e "${YELLOW}Deleting k3d cluster...${NC}"
k3d cluster delete p3

echo -e "${GREEN}Full clean completed successfully!${NC}" 