#!/bin/sh -x

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

OUTPUT=${HERE}/output
TARGET="${HOME}/resilio-sync/sync/Flight Tracks"

mkdir -p "${TARGET}/heatmaps"

rsync -avr "${OUTPUT}/" "${TARGET}/heatmaps/"
