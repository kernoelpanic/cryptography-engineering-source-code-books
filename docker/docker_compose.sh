#!/bin/bash
# Setup docker environment for tutorial
set -e

DOCKER_NETWORK_NAME="pptnet"

if [ -z "${1}" ] && [ -z "${DOCKER_FILE+x}" ];
then 
	export DOCKER_FILE="ubuntu_ppt"
elif [ ! -z "${1}" ];
then
	export DOCKER_FILE="${1}"
fi

if [ -z "${2}" ] && [ -z "${DOCKER_UID+x}" ];
then 
	export DOCKER_UID=$(id -u)
elif [ ! -z "${2}" ];
then
	export DOCKER_UID="${2}"
fi

if [ -z "${3}" ] && [ -z "${DOCKER_GID+x}" ];
then 
	export DOCKER_GID=$(id -g)
elif [ ! -z "${3}" ];
then
	export DOCKER_GID="${3}"
fi

# Build Container 
# Get uid and gid of current user
# In most cases this will be 1000
# Take care that this user is in the docker group
#docker build --no-cache --build-arg UID=${DOCKER_UID} --build-arg GID=${DOCKER_GID} -f ${DOCKER_FILE}.Dockerfile -t ${DOCKER_FILE}:latest .
docker build --build-arg UID=${DOCKER_UID} --build-arg GID=${DOCKER_GID} -f ${DOCKER_FILE}.Dockerfile -t ${DOCKER_FILE}:latest .
