#!/bin/sh -x

if [ -z ${WORKSPACE} ]
then
    HERE=$(dirname $0)
else
    HERE=${WORKSPACE}
fi

DATA=${HERE}/data
DATA=$(realpath ${DATA})

SOURCE="${HOME}/resilio-sync/sync/Flight Tracks"

if [ -d "/mnt/blacklibrary/aviation/tracks" ]
then
    SOURCE="/mnt/blacklibrary/aviation/tracks"
fi

mkdir -p ${DATA}

cp "${SOURCE}"/gpx/* ${DATA}
cp "${SOURCE}"/kml/* ${DATA}

for year in $(seq 2020 2030)
do
    mkdir -p ${DATA}/${year}
    mv ${DATA}/*${year}*.* ${DATA}/${year}

    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
	mkdir -p ${DATA}/${year}-${month}
	cp ${DATA}/${year}/*${year}-${month}*.* ${DATA}/${year}-${month}
    done
done

find ${DATA} -type d -a -empty | xargs --no-run-if-empty rmdir

for d in ${DATA}/???? ${DATA}/????-??
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





