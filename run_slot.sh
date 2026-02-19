#!/bin/bash

BASE="/home/ansible"
SLOT="$1"

SCHEDULE="$BASE/schedules/$SLOT.txt"
LOGBASE="$BASE/logs/$SLOT"
DATE=$(date +"%Y-%m-%d_%H-%M")

if [ ! -f "$SCHEDULE" ]; then
  echo "Schedule $SLOT not found"
  exit 1
fi

mkdir -p "$LOGBASE"

while read -r PB; do
  [ -z "$PB" ] && continue

  REGION=$(dirname "$PB")
  NAME=$(basename "$PB" .yml)

  LOGDIR="$LOGBASE/$REGION"
  mkdir -p "$LOGDIR"

  /usr/bin/flock -n "/tmp/${SLOT}_${NAME}.lock" \
    /usr/bin/ansible-playbook \
    "$BASE/playbooks/$PB" \
    >> "$LOGDIR/${NAME}_$DATE.log" 2>&1 &

done < "$SCHEDULE"

wait
