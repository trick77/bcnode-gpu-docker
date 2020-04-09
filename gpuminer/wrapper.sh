#!/bin/sh
set -e

echo "*** Let's see if we have access to the GPU from within the container:"
nvcc --version
nvidia-smi
# Periodically terminate (Docker will restart it automatically) the
# GPU miner to clear "some nasty work backup". You'd have to ask LG.
echo "*** Starting miner..."
timeout -s INT 5m ./miner
echo "*** Terminating miner (this is NOT an error!)..."
echo
