#!/bin/sh -x

export DOCKER_IMAGE_NAME=gshome/flight-heatmap
export DOCKER_IMAGE=${DOCKER_IMAGE_NAME}:latest

export NAME=heatmap-$(id -un)

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

DATA=${HERE}/data
DATA=$(realpath ${DATA})

BOUNDS=${HERE}/bounds
BOUNDS=$(realpath ${BOUNDS})

OUTPUT=${HERE}/output
OUTPUT=$(realpath ${OUTPUT})

if [ -r ${HERE}/secrets.sh ]
then
    . ${HERE}/secrets.sh
fi


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

        -a|--all)
            for d in ${DATA}/*
            do
                YEARS="${YEARS} $(basename ${d})"
            done
            ;;

        *)
            YEARS="${YEARS} ${arg}"
            ;;
    esac
done

if [ -z "${YEARS}" ]
then
    YEARS="2024 2024-08 2024-08-30 2024-09"
fi

for YEAR in ${YEARS}
do
    rm -rf ${OUTPUT}/${YEAR}
    mkdir -p ${OUTPUT}/${YEAR}

    if [ -r ${BOUNDS}/${YEAR}/bounds.json ]
    then
        cp ${BOUNDS}/${YEAR}/bounds.json ${OUTPUT}/${YEAR}/bounds.json
    fi

    echo ${YEAR} > ${OUTPUT}/${YEAR}/title.txt

    docker run \
           --rm \
           ${SHELL_MODE} \
           --name ${NAME} \
           --hostname ${NAME} \
           --env USER_ID=$(id -u) \
           --env MAPBOX_API_KEY=${MAPBOX_API_KEY} \
           --env OPENAIP_API_KEY=${OPENAIP_API_KEY} \
           --volume /etc/localtime:/etc/localtime:ro \
           --volume /etc/timezone:/etc/timezone:ro \
           --volume /etc/resolv.conf:/etc/resolv.conf:ro \
           --mount type=bind,source=${DATA}/${YEAR},target=/app/gpx_files \
           --mount type=bind,source=${OUTPUT}/${YEAR},target=/app/output \
           ${DOCKER_IMAGE}
done
