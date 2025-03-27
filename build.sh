#!/bin/sh -x

NO_CACHE="$1"

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

if [ "${DOCKER_IMAGE_NAME}x" = "x" ]
then
    export DOCKER_IMAGE_NAME=hakan42/flight-heatmap
fi

# Allow cache to be bypassed
if [ "x${NO_CACHE}x" = "xtruex" ];
then
    echo " ---> Skipping cache"
else
    NO_CACHE="false"
fi

if [ -z ${TAG} ]
then
    TAG=latest
fi

# Build from working directory
( cd ${HERE} && \
        docker build --no-cache=${NO_CACHE} \
               -f ${HERE}/Dockerfile \
               -t ${DOCKER_IMAGE_NAME}:${TAG} \
               -t ${DOCKER_IMAGE_NAME}:latest \
               . )

docker images | grep heatmap
