#!/bin/sh
SERVICE=frontend-v2
ROUTE=frontend
PROJECT=namespace-1
oc patch route $ROUTE  -p '{"spec":{"to":{"name":"'$SERVICE'"}}}' -n $PROJECT