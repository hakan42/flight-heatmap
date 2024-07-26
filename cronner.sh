#!/bin/sh

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

HERE=$(realpath ${HERE})
LOG=${HERE}/data/log

rm -rf ${HERE}/data
mkdir -p ${LOG}

export NAME=heatmap-$(id -un)
docker rm -f ${NAME}        > ${LOG}/docker-rm.out     2> ${LOG}/docker-rm.err

sh -x ${HERE}/fetch-data.sh    > ${LOG}/fetch-data.out    2> ${LOG}/fetch-data.err
sh -x ${HERE}/run.sh --all     > ${LOG}/run.out           2> ${LOG}/run.err
sh -x ${HERE}/push-heatmaps.sh > ${LOG}/push-heatmaps.out 2> ${LOG}/push-heatmaps.err
