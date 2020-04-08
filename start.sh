#!/usr/bin/env bash
set -e

gpuminer_image="local/gpuminer:latest"
bcnode_image="local/bcnode:latest"

echo
echo "*** If this script fails, you may want to ./cleanup.sh before starting it again."
echo
echo "!!! Check the following output if Docker has access to one or more GPUs:"
docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi

if [ -z "${BC_MINER_KEY}" ]; then
  echo
  echo "Error: Miner key missing in the environment. Do something like export BC_MINER_KEY=\"0x..yourminerkey\""
  echo "Aborting."
  exit 1
fi

if [ -z "${BC_SCOOKIE}" ]; then
  echo
  echo "Error: Scookie is missing in the environment. Do something like export BC_SCOOKIE=\"s3cr3t\""
  echo "Aborting."
  exit 1
fi

echo "*** Creating a comfy Docker network for the containers..."
docker network create waietng

echo "*** Firing up a container for LG's GPU miner..."
docker run --rm --name gpuminer \
--gpus all \
-p 50052 -d \
--network waietng \
${gpuminer_image} 2>&1

echo "*** Starting bcnode container..."
docker run --rm --name bcnode \
--memory-reservation="6900m" \
-p 3000:3000 -p 16060:16060/tcp -p 16060:16060/udp -p 16061:16061/tcp -p 16061:16061/udp -d \
-e BC_MINER_KEY="${BC_MINER_KEY}" \
-e BC_NETWORK="main" \
-e MIN_HEALTH_NET=true \
-e BC_TUNNEL_HTTPS=true \
-e BC_RPC_MINER=true \
-e NODE_OPTIONS=--max_old_space_size=6096 \
--network waietng \
--mount source=db,target=/bc/_data \
${bcnode_image} \
start --rovers --rpc --ws --ui --node --scookie "${BC_SCOOKIE}" 2>&1
echo "*** Done."
echo
docker ps
echo
echo "Verify everything runs smoothly with: docker logs -f bcnode --tail 100"
echo "For the GPU miner:  docker logs -f gpuminer --tail 100"
echo "Hit CTRL-C to abort the output."
echo
echo "Use ./cleanup.sh to stop the miner before restarting it."
