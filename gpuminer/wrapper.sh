#!/bin/sh
set -e

# Some keepalive shit LG says is required. "This is the way."
export LD_LIBRARY_PATH="/root/grpc/build:$LD_LIBRARY_PATH"
while true; do
    timeout -s 9 60m ./miner
done
