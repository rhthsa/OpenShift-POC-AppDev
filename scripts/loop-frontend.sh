#!/bin/sh
URL=https://$(oc get route frontend -n namespace-1 -o jsonpath='{.spec.host}')
COUNT=1
while [ 1 ];
do 
    echo "\nLoop: $COUNT"
    curl $URL
    COUNT=$(expr $COUNT + 1)
done