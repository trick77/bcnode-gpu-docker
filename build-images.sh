#!/usr/bin/env bash

# Always fetch latest GPU miner sources when rebuilding
docker build --build-arg CACHEBUST=$(date +%s) -t local/gpuminer -f Dockerfile.gpuminer .

# Always pull new upstream image if available
docker pull blockcollider/bcnode:latest
docker build -t local/bcnode -f Dockerfile.bcnode .
