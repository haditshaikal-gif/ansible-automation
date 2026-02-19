#!/bin/bash

PRTG_SERVER="https://100.6.0.70"
USERNAME="prtgadmin"
PASSHASH="2987465562"

SENSOR_FILE="/home/ansible/PRTG/sensor_id_01_15.txt"
BASE_OUTDIR="/home/ansible/PRTG/Graph"

TODAY=$(date +"%Y-%m-%d")
OUTDIR="${BASE_OUTDIR}/${TODAY}"

mkdir -p "$OUTDIR"

while IFS='|' read -r SENSOR_ID SITE_ID; do
  # skip empty / invalid line
  [ -z "$SENSOR_ID" ] || [ -z "$SITE_ID" ] && continue

  OUTFILE="${OUTDIR}/${SITE_ID}_${SENSOR_ID}.svg"

  curl -sk \
    "$PRTG_SERVER/chart.svg?id=${SENSOR_ID}&graphid=0&timespan=3600&width=1200&height=500&username=${USERNAME}&passhash=${PASSHASH}" \
    -o "$OUTFILE"

  echo "Captured ${SITE_ID} (Sensor ${SENSOR_ID}) -> ${OUTFILE}"

done < "$SENSOR_FILE"
