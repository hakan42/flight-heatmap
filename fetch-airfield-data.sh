#!/bin/sh -e

FLIGHTS=/mnt/blacklibrary/aviation/tracks/csv/Export-g.csv
FLIGHTS_CLEAN=/tmp/Export-g-$$.cvs

cat ${FLIGHTS} | grep -v Bemerkung | grep -v Zeitspanne > ${FLIGHTS_CLEAN}

if [ -r ${FLIGHTS_CLEAN} ]
then
    while IFS= read -r line; do

        # Remove quotes from the entire line
        line=$(echo "$line" | sed 's/"//g')

        DATE=$(echo ${line} | cut -d';' -f1)
        # Convert the date format from dd.mm.yyyy to yyyy-mm-dd
        DATE_YYYY_MM_DD=$(echo "$DATE" | awk -F'.' '{ printf("%s-%s-%s", $3, $2, $1) }')
        DATE_YYYY_MM=$(echo "$DATE" | awk -F'.' '{ printf("%s-%s", $3, $2, $1) }')
        DATE_YYYY=$(echo "$DATE" | awk -F'.' '{ printf("%s", $3, $2, $1) }')

        AD_FROM=$(echo ${line} | cut -d';' -f4)
        AD_FROM_ICAO=$(echo "${AD_FROM}" | awk '{print $NF}')

        AD_TO=$(echo ${line} | cut -d';' -f5)
        AD_TO_ICAO=$(echo "${AD_TO}" | awk '{print $NF}')

        # echo ${DATE} - ${DATE_YYYY_MM_DD} - ${DATE_YYYY_MM} - ${DATE_YYYY} - ${AD_FROM} - ${AD_TO} - ${AD_FROM_ICAO} - ${AD_TO_ICAO}

        if [ -r "${DATA}/${AD_FROM_ICAO}-Platzrunde-g.gpx" ]
        then
            if [ -d ${DATA}/${DATE_YYYY} ]
            then
                cp ${DATA}/${AD_FROM_ICAO}-* ${DATA}/${DATE_YYYY}
            fi

            if [ -d ${DATA}/${DATE_YYYY_MM} ]
            then
                cp ${DATA}/${AD_FROM_ICAO}-* ${DATA}/${DATE_YYYY_MM_DD}
            fi

            if [ -d ${DATA}/${DATE_YYYY_MM} ]
            then
                cp ${DATA}/${AD_FROM_ICAO}-* ${DATA}/${DATE_YYYY_MM_DD}
            fi
        fi

        if [ -r "${DATA}/${AD_TO_ICAO}-Platzrunde-g.gpx" ]
        then
            if [ -d ${DATA}/${DATE_YYYY} ]
            then
                cp ${DATA}/${AD_TO_ICAO}-* ${DATA}/${DATE_YYYY}
            fi

            if [ -d ${DATA}/${DATE_YYYY_MM} ]
            then
                cp ${DATA}/${AD_TO_ICAO}-* ${DATA}/${DATE_YYYY_MM_DD}
            fi

            if [ -d ${DATA}/${DATE_YYYY_MM} ]
            then
                cp ${DATA}/${AD_TO_ICAO}-* ${DATA}/${DATE_YYYY_MM_DD}
            fi
        fi

    done < "${FLIGHTS_CLEAN}"
fi

rm -f ${FLIGHTS_CLEAN}
