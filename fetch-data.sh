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

cp "${SOURCE}"/csv/* ${DATA}
cp "${SOURCE}"/gpx/* ${DATA}
cp "${SOURCE}"/kml/* ${DATA}
cp "${SOURCE}"/pln/* ${DATA}

find ${DATA} -name LOG\*     -exec rm {} \;
find ${DATA} -name QTravel\* -exec rm {} \;

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

if [ -r ${HERE}/fetch-misc.sh ]
then
    . ${HERE}/fetch-misc.sh
fi

mkdir ${DATA}/pre-corona
cp -avr ${DATA}/2020/* ${DATA}/pre-corona

mkdir ${DATA}/restarted
cp -avr ${DATA}/2021/* ${DATA}/restarted
cp -avr ${DATA}/2023/* ${DATA}/restarted
cp -avr ${DATA}/2024/* ${DATA}/restarted

# Post-Solo, Pre-Checkride
mkdir -p ${DATA}/post-solo
cp -avr ${DATA}/2024-06/* ${DATA}/post-solo
cp -avr ${DATA}/2024-07/* ${DATA}/post-solo
cp -avr ${DATA}/2024-08/* ${DATA}/post-solo
cp -avr ${DATA}/2024-09/* ${DATA}/post-solo
cp -avr ${DATA}/2024-10/* ${DATA}/post-solo
cp -avr ${DATA}/2024-11/* ${DATA}/post-solo

rm -f ${DATA}/post-solo/*2024-06-04*
rm -f ${DATA}/post-solo/*2024-06-18*
rm -f ${DATA}/post-solo/*2024-06-24*

# We don't have good data in EDML during 2023
rm -f ${DATA}/restarted/*2023-08-*
