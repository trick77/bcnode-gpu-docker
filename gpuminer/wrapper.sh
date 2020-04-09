#!/bin/sh
set -e

export LD_LIBRARY_PATH="/root/grpc/build:$LD_LIBRARY_PATH"

echo "*** Let's see if we have access to the GPU from within the container:"
nvcc --version
nvidia-smi
# Periodically terminate (Docker will restart it automatically) the
# GPU miner to clear "some nasty work backup". You'd have to ask LG.
echo "*** Starting the miner..."
timeout -s INT 5m ./miner
echo "*** Terminating GPU miner (this is NOT an error!)..."
echo
