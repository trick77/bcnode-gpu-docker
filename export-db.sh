#!/usr/bin/env bash

function exists() { command -v "$1" >/dev/null 2>&1 ; }

set -euo pipefail

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

timestamp=`date +%Y-%m-%d_%H-%M-%S`
bcnode_container_name=bcnode
database_volume_name=db

while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare ${param}="true"
  fi
  shift
done

if ! exists awk || ! exists pv || ! exists gzip ; then
  echo >&2 -e "${RED}Error: searching PATH fails to find executables among: awk pv gzip ${NC}"
  exit 1
fi

existing_volume=$(docker volume ls -q -f name=${database_volume_name} | grep -w ${database_volume_name}) || true
if [ -z ${existing_volume} ]; then
  echo >&2 -e "${RED}Error: No named Docker volume \"${database_volume_name}\" found!${NC}"
  exit 1
fi

docker rm -f exportdb > /dev/null 2>&1 || true

# This way the export can run even if bcnode isn't running atm (which is probably safer anyway)
echo -e "${GREEN}Starting dummy container to access ${database_volume_name} volume...${NC}"
docker run -d --rm --name exportdb -v ${database_volume_name}:/root alpine tail -f /dev/null

tmp_dir=`mktemp -d`
echo -e "${GREEN}Extracting local blockchain database to ${tmp_dir}...${NC}"
docker cp exportdb:/root ${tmp_dir}/_data

echo -e "${GREEN}Compressing database, this will take a while...${NC}"
cwd=$(pwd)
cd ${tmp_dir}
rm ./_data/.chainstate.db
rm ./_data/db/IDENTITY
rm ./_data/db/LOCK
tar cf - ./ -P | pv -s $(du -sb ./ | awk '{print $1}') | gzip > ${cwd}/bcnode-db-${timestamp}.tar.gz

echo -e "${GREEN}Cleaning up...${NC}"
docker rm -f exportdb > /dev/null 2>&1
rm -rf ${tmp_dir}

echo -e "${GREEN}Done.${NC}"
echo "bcnode-db-${timestamp}.tar.gz"
