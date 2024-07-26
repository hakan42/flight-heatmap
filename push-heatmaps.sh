#!/bin/sh -x

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

OUTPUT=${HERE}/output
TARGET="${HOME}/resilio-sync/sync/Flight Tracks"

if [ -d "/mnt/blacklibrary/aviation/tracks" ]
then
    TARGET="/mnt/blacklibrary/aviation/tracks"
fi

mkdir -p "${TARGET}/heatmaps"

rsync -avr "${OUTPUT}/" "${TARGET}/heatmaps/"
