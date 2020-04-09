#!/usr/bin/env bash
set -e

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

echo -e "${GREEN}Refreshing this Git repository...${NC}"
git pull
echo

echo -e "${GREEN}Rebuilding GPU miner sources... (this might take some time)${NC}"
docker build --build-arg CACHEBUST=$(date +%s) -t local/gpuminer -f Dockerfile.gpuminer .
echo

echo -e "${GREEN}Removing intermediate build products...${NC}"
docker image prune -f
docker rmi nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
echo

echo -e "${GREEN}Pulling latest upstream image...${NC}"
docker pull blockcollider/bcnode:latest
echo

echo -e "${GREEN}Building new image...${NC}"
docker build -t local/bcnode -f Dockerfile.bcnode .
echo

echo -e "${GREEN}Removing original bcnode image...${NC}"
docker rmi blockcollider/bcnode:latest
echo

echo -e "${GREEN}Showing all locally available Docker images:${NC}"
docker images

echo -e "${GREEN}Done.${NC}"
