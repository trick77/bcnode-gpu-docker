#!/usr/bin/env bash
set -eo pipefail

. ../config

{
curl -s --basic --user ":${BC_SCOOKIE}" http://localhost:3000/rpc \
    -H "content-type: application/json" \
    -H "accept: application/json" \
    -d  @- <<EOF
{
  "jsonrpc": "2.0",
  "id": 123,
  "method": "getSettings",
  "params": []
}
EOF
} | jq  --raw-output '.result.ngrokTunnel'
