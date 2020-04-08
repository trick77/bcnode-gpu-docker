#!/bin/sh
set -e

export LD_LIBRARY_PATH="/root/grpc/build:$LD_LIBRARY_PATH"

# Terminate the GPU miner every hour. You'd have to ask LG.
timeout -s INT 60m ./miner
