#!/bin/sh
set -e

export LD_LIBRARY_PATH="/root/grpc/build:$LD_LIBRARY_PATH"

# Periodically terminate (Docker will restart it automatically) the
# GPU miner to clear "some nasty work backup". You'd have to ask LG.
timeout -s INT 5m ./miner
