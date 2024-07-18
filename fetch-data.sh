#!/bin/sh -x

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

DATA=${HERE}/data
SOURCE="${HOME}/resilio-sync/sync/Flight Tracks"

# rm -rf ${DATA}
# mkdir -p ${DATA}

# cp "${SOURCE}"/gpx/* ${DATA}
# cp "${SOURCE}"/kml/* ${DATA}

for year in $(seq 2020 2030)
do
    mkdir ${DATA}/${year}
    mv ${DATA}/*${year}*.* ${DATA}/${year}
done

find ${DATA} -type d -a -empty | xargs --no-run-if-empty rmdir

for d in ${DATA}/????
do
    cd ${d}
    for k in *.kml
    do
	g=$(basename "$k" .kml).gpx
	if [ -r "${g}" ]
	then
	    rm -f "${k}"
	fi
    done
done





