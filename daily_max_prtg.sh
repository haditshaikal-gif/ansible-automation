#!/bin/bash

# =========================
# CONFIG
# =========================
PRTG_SERVER="https://100.6.0.70"
USERNAME="prtgadmin"
PASSHASH="2987465562"

SENSOR_FILE="/home/ansible/PRTG/sensor_id_all.txt"
OUTDIR="/home/ansible/PRTG/Daily_MAX"

AVG=0  #no interval

mkdir -p "$OUTDIR"

# =========================
# DATE (REPORT DATE = TODAY)
# Range: 00:00 - 03:00
# =========================
REPORT_DATE=$(date +"%Y-%m-%d")

SDATE="${REPORT_DATE}-00-00-00"
EDATE="${REPORT_DATE}-03-00-00"

OUTFILE="$OUTDIR/${REPORT_DATE}.csv"

# =========================
# CSV HEADER
# =========================
echo "Date,SiteID,SensorID,MaxTrafficIn_bps" > "$OUTFILE"

# =========================
# LOOP SENSOR LIST
# =========================
while IFS='|' read -r SENSOR_ID SITE_ID; do
  [[ -z "$SENSOR_ID" || -z "$SITE_ID" ]] && continue

  TMPFILE=$(mktemp)

  # =========================
  # FETCH HISTORIC DATA
  # =========================
  curl -k -s \
    "$PRTG_SERVER/api/historicdata.csv?id=$SENSOR_ID&sdate=$SDATE&edate=$EDATE&avg=$AVG&username=$USERNAME&passhash=$PASSHASH" \
    -o "$TMPFILE"

  # =========================
  # GET MAX Traffic In (RAW)
  # Column 10 = Traffic In (speed)(RAW)
  # RAW = Byte/s ? bit/s = x8
  # =========================
  MAX_IN_BPS=$(awk '
  BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")"
  }
    NR>1 {
      gsub(/"/,"",$10)
      if ($10 > 0) {
        val = ($10 * 8) / 1000000
        if (val > max) max = val
      }
    }
    END {
      if (max > 0)
        printf "%.3f\n", max
      else
        print "0"
    }
  ' "$TMPFILE")

  # =========================
  # WRITE RESULT
  # =========================
  echo "$REPORT_DATE,$SITE_ID,$SENSOR_ID,$MAX_IN_BPS" >> "$OUTFILE"

  rm -f "$TMPFILE"

  echo "? $SITE_ID | Sensor $SENSOR_ID | Max In = $MAX_IN_BPS Mbps"

done < "$SENSOR_FILE"
