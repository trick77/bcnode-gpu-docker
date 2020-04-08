#!/usr/bin/env bash

echo "*** Killing containers if running, cleaning up..."
docker rm -f bcnode
docker rm -f gpuminer
docker network rm waietng
