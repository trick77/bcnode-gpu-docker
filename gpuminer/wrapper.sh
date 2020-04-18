#!/bin/sh
set -e

echo "*** Check the following output if this container has access to one or more GPUs:"
nvidia-smi
echo "*** Starting miner..."
./miner
echo
