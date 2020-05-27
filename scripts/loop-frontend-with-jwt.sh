#!/bin/sh
URL=http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user1-istio-system)
COUNT=1
while [ 1 ];
do 
    echo "\nLoop: $COUNT"
    curl -H "Authorization: Bearer $(cat artifacts/token.txt)" $URL
    COUNT=$(expr $COUNT + 1)
done