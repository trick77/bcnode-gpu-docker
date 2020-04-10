#!/usr/bin/env bash
set -eo pipefail

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
  fi
  shift
done

if [ ! -z ${nopurge} ]; then
  echo -e "${YELLOW}Purging intermediate build products is disabled. This will use more disk space.${NC}"
fi

if [ ! -z ${nopull} ]; then
  echo -e "${YELLOW}Latest upstream image will not be pulled if it doesn't already exist.${NC}"
fi

if [ ! -z ${nogpubuild} ]; then
  echo -e "${YELLOW}Image build for the gpuminer disabled.${NC}"
fi

echo -e "${GREEN}Refreshing this Git repository...${NC}"
git pull
echo

if [ -z ${nogpubuild} ]; then
  echo -e "${GREEN}Rebuilding GPU miner sources... (this might take some time)${NC}"
  docker build --build-arg CACHEBUST=$(date +%s) -t local/gpuminer -f Dockerfile.gpuminer .
  echo
fi

if [ -z ${nopurge} ]; then
  echo -e "${GREEN}Removing intermediate build products...${NC}"
  docker image prune -f
  docker rmi nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
  echo
fi

if [ -z ${nopull} ]; then
  echo -e "${GREEN}Pulling latest upstream image...${NC}"
  docker pull blockcollider/bcnode:latest
echo
fi

echo -e "${GREEN}Building new image...${NC}"
docker build -t local/bcnode -f Dockerfile.bcnode .
echo

if [ -z ${nopurge} ]; then
  echo -e "${GREEN}Removing original bcnode image...${NC}"
  docker rmi blockcollider/bcnode:latest
  echo
fi

echo -e "${GREEN}Showing all locally available Docker images:${NC}"
docker images

echo -e "${GREEN}Done.${NC}"
