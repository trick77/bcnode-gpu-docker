#!/usr/bin/env bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

echo -e "${GREEN}Killing containers if running, cleaning up...${NC}"
docker rm -f bcnode
docker rm -f gpuminer
docker network rm waietng
