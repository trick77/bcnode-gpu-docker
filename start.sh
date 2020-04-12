#!/usr/bin/env bash
set -e pipefail

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

gpuminer_image="local/gpuminer:latest"
bcnode_image="local/bcnode:latest"

echo
echo -e "${RED}Make sure to manually run ./cleanup.sh before starting this script!${NC}"
echo
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
export PATH=${PATH}:${CUDA_HOME}/bin
echo -e "${GREEN}Let's see if and which version of Nvidia CUDA is available on the host:${NC}"
nvidia-smi | head -3 | tail -1
echo

echo -e "${GREEN}Check the following output if Docker has access to one or more GPUs:${NC}"
docker run --rm --gpus all nvidia/cuda:10.2-base-ubuntu18.04 nvidia-smi

if [ -z "${BC_MINER_KEY}" ]; then
  echo
  echo -e "${RED}Error: Miner key missing in the environment. Do something like export BC_MINER_KEY=\"0xc0ffee...\""
  echo -e "Aborting.${NC}"
  exit 1
fi

if [ -z "${BC_SCOOKIE}" ]; then
  echo
  echo -e "${RED}Error: Scookie is missing in the environment. Do something like export BC_SCOOKIE=\"s3cr3t\""
  echo -e "Aborting.${NC}"
  exit 1
fi

echo -e "${GREEN}Creating a comfy Docker network for the containers...${NC}"
docker network create waietng

echo -e "${GREEN}Firing up a container for LG's GPU miner...${NC}"
docker run --restart=unless-stopped  --name gpuminer \
--gpus all \
-p 50052 -d \
--network waietng \
${gpuminer_image} 2>&1

echo -e "${GREEN}Starting bcnode container...${NC}"
docker run --restart=unless-stopped --name bcnode \
--memory-reservation="6900m" \
-p 3000:3000 -p 16060:16060/tcp -p 16060:16060/udp -p 16061:16061/tcp -p 16061:16061/udp -d \
-e BC_MINER_KEY="${BC_MINER_KEY}" \
-e BC_NETWORK="main" \
-e MIN_HEALTH_NET=true \
-e BC_TUNNEL_HTTPS=true \
-e BC_RPC_MINER=true \
-e BC_MINER_WORKERS=1 \
-e NODE_OPTIONS=--max_old_space_size=6096 \
--network waietng \
--mount source=db,target=/bc/_data \
${bcnode_image} \
start --rovers --rpc --ws --ui --node --scookie "\"${BC_SCOOKIE}\"" 2>&1
echo -e "${GREEN}Done.${NC}"
echo
docker ps
echo
echo -e "${YELLOW}Verify everything runs smoothly with: docker logs -f bcnode --tail 100"
echo -e "For the GPU miner:  docker logs -f gpuminer --tail 100"
echo -e "Hit CTRL-C to abort the output."
echo
echo -e "Use ./cleanup.sh to stop the miner before restarting it."
echo
echo -e "Use git pull to refresh this Git repository every now and then."
echo -e "${NC}"
