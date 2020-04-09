#!/bin/sh
set -e

echo "*** Let's see if and which version of Nvidia CUDA is available in the container:"
#nvcc --version
echo "*** Check the following output if this container has access to one or more GPUs:"
nvidia-smi
# Periodically terminate (Docker will restart it automatically) the
# GPU miner to clear "some nasty work backup". You'd have to ask LG.
echo "*** Starting miner..."
timeout -s INT 5m ./miner
echo "*** Terminating miner (this is NOT an error!)..."
echo
