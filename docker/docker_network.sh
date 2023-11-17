#!/bin/bash
# Setup docker environment for tutorial
#set -e

if [ -z "${1}" ] && [ -z "${DOCKER_NETWORK_NAME+x}" ];
then 
	export DOCKER_NETWORK_NAME="pptnet"
elif [ ! -z "${1}" ];
then
	export DOCKER_NETWORK_NAME="${1}"
fi

if [ -z "${2}" ] && [ -z "${DOCKER_NETWORK_SUBNET+x}" ];
then 
	export DOCKER_NETWORK_SUBNET="172.23.0.0/16"
elif [ ! -z "${2}" ];
then
	export DOCKER_NETWORK_SUBNET="${2}"
fi


echo "Checking for network '${DOCKER_NETWORK_NAME}'"
# check if network exists if not create it
FOUND_NETWORK=$(docker network ls | grep "${DOCKER_NETWORK_NAME}")

if [[ -z ${FOUND_NETWORK} ]]; 
then
  echo "Network '${DOCKER_NETWORK_NAME}' not yet specified"
  docker network create --subnet="${DOCKER_NETWORK_SUBNET}" --driver bridge "${DOCKER_NETWORK_NAME}"
fi

echo
docker network ls
echo
docker images
