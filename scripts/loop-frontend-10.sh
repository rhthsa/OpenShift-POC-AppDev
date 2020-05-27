#!/bin/sh
COUNT=0
MAX=10
VERSION1=0
VERSION2=0
TARGET_URL=https://$(oc get route frontend -n namespace-1 -o jsonpath='{.spec.host}')
while [ $COUNT -lt $MAX ];
do
  # OUTPUT=$(curl $TARGET_URL -s -w "Elapsed Time:%{time_total}")
  OUTPUT=$(curl $TARGET_URL -s -w "Elapsed Time:%{time_total}")
  # HOST=$(echo $OUTPUT|awk -F'Host:' '{print $2}'| awk -F',' '{print $1}')
  VERSION=$(echo $OUTPUT|awk -F'Frontend version:' '{print $2}'| awk -F'=>' '{print $1}')
  echo "Frontend:$VERSION"
  COUNT=$(expr $COUNT + 1)
      if [ $VERSION == "v1" ];
       then
         VERSION1=$(expr $VERSION1 + 1)
       fi
      if [ $VERSION == "v2" ];
       then
         VERSION2=$(expr $VERSION2 + 1)
       fi
done
echo "========================================================"
echo "Version v1: $VERSION1"
echo "Version v2: $VERSION2"
echo "========================================================"
