#!/bin/sh
if [ `uname` == "Darwin" ] ; then
  alias md5sum='md5 -r'
else
  alias md5sum='md5sum'
fi
if [ "A$1" == "A" ] ; then
  echo "You must supply the name of the file to use as a probe"
  exit 2
fi
PROBE="$1"
DELTA="$(mktemp "$PROBE.XXXXXX")"
if [ "A$2" == "A" ] ; then
  WORK=60
else
  WORK=$2
fi
echo "Starting probe $PROBE [pid=$$]"
echo "[$(date),pid=$$] Starting probe $PROBE" | tee "$DELTA" > "$PROBE"
for n in $(seq 1 $WORK) ; do
  printf "."
  echo "[$(date),pid=$$] Work $n: $RANDOM" | tee -a "$DELTA" >> "$PROBE"
  sleep 1
done
echo " done"
echo "[$(date),pid=$$] Finished probe $PROBE: $RANDOM" | tee -a "$DELTA" >> "$PROBE"
PROBE_MD5=$(md5sum "$PROBE" | sed -e "s/\(^.*\) .*/\1/")
DELTA_MD5=$(md5sum "$DELTA" | sed -e "s/\(^.*\) .*/\1/")
echo "Probe $PROBE hash found: $PROBE_MD5 expecting: $DELTA_MD5"

rm -f "$DELTA"
if [ "$PROBE_MD5" == "$DELTA_MD5" ] ; then
  echo "SUCCESS"
else
  cat "$PROBE" | sed -ne "s/^/    /p;"
  echo "FAILURE"
  exit 1
fi
