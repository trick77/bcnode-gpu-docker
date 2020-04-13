#!/usr/bin/env bash
set -eo pipefail

. ../config
curl -s --basic --user ":${BC_SCOOKIE}" -H "content-type: application/json" -H "accept: application/json" -d '{ "jsonrpc": "2.0", "id": 123, "method": "getSettings", "params": [] }' http://localhost:3000/rpc | jq  --raw-output '.result.ngrokTunnel'
