#!/bin/bash

# =========================
# CONFIG
# =========================
PRTG_SERVER="https://100.6.0.70"
USERNAME="prtgadmin"
PASSHASH="2987465562"

SENSOR_FILE="/home/ansible/PRTG/sensor_id_all.txt"
OUTDIR="/home/ansible/PRTG/Weekly_RAW"

AVG=0   # no interval minutes

mkdir -p "$OUTDIR"

# =========================
# DATE RANGE (Minggu - Sabtu)
# =========================
SDATE=$(date -d "last sunday" +"%Y-%m-%d-00-00-00")
EDATE=$(date -d "last sunday +6 days" +"%Y-%m-%d-23-59-59")

# =========================
# WEEKLY FOLDER (YYYYMMDD-YYYYMMDD)
# =========================
WEEK_START=$(date -d "last sunday" +"%Y%m%d")
WEEK_END=$(date -d "last sunday +6 days" +"%Y%m%d")

WEEK_FOLDER="${WEEK_START}-${WEEK_END}"
OUTDIR_WEEKLY="$OUTDIR/$WEEK_FOLDER"

mkdir -p "$OUTDIR_WEEKLY"

# =========================
# LOOP SENSOR|SITE
# =========================
while IFS='|' read -r SENSOR_ID SITE_ID; do
  [[ -z "$SENSOR_ID" || -z "$SITE_ID" ]] && continue

  OUTFILE="$OUTDIR_WEEKLY/${SITE_ID}_sensor_${SENSOR_ID}.csv"
  TMPFILE=$(mktemp)

  curl -k -s \
    "$PRTG_SERVER/api/historicdata.csv?id=$SENSOR_ID&sdate=$SDATE&edate=$EDATE&avg=$AVG&username=$USERNAME&passhash=$PASSHASH" \
    -o "$TMPFILE"

  awk -F',' -v site="$SITE_ID" '
    NR==1 { print "SiteID," $0; next }
    { print site "," $0 }
  ' "$TMPFILE" > "$OUTFILE"

  rm -f "$TMPFILE"

  echo "✔ Exported $SITE_ID (Sensor $SENSOR_ID)"

done < "$SENSOR_FILE"
