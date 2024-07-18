#!/bin/sh -x

export DOCKER_IMAGE_NAME=gshome/flight-heatmap
export DOCKER_IMAGE=${DOCKER_IMAGE_NAME}:latest

export NAME=heatmap-$(id -un)


SHELL_MODE="-it"
ARGUMENTS=""
YEARS=""

for arg in $@
do
    case "${arg}" in
        -s|--shell)
            SHELL_MODE="-it --entrypoint /bin/bash"
            ;;

        -d|--docker)
            SHELL_MODE=""
            ;;

        *)
            YEARS="${YEARS} ${arg}"
            ;;
    esac
done

if [ -z "${YEARS}" ]
then
    YEARS=2024
fi
     

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

DATA=${HERE}/data
DATA=$(realpath ${DATA})

OUTPUT=${HERE}/output
OUTPUT=$(realpath ${OUTPUT})

for YEAR in ${YEARS}
do
    rm -rf ${OUTPUT}/${YEAR}
    mkdir -p ${OUTPUT}/${YEAR}

    docker run \
           --rm \
           ${SHELL_MODE} \
           --name ${NAME} \
           --hostname ${NAME} \
           --env USER_ID=$(id -u) \
           --volume /etc/localtime:/etc/localtime:ro \
           --volume /etc/timezone:/etc/timezone:ro \
           --volume /etc/resolv.conf:/etc/resolv.conf:ro \
           --mount type=bind,source=${DATA}/${YEAR},target=/app/gpx_files \
           --mount type=bind,source=${OUTPUT}/${YEAR},target=/app/output \
           ${DOCKER_IMAGE}
done