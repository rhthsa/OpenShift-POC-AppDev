#!/bin/sh
oc delete -f artifacts/backend-destination-rule.yaml -n namespace-2
oc delete -f artifacts/frontend-destination-rule-mtls.yaml -n namespace-1
oc delete -f artifacts/frontend-destination-rule.yaml -n namespace-1
oc delete -f artifacts/backend-virtual-service.yaml -n namespace-2
oc delete -f artifacts/frontend-virtual-service.yaml -n namespace-1
oc delete -f artifacts/frontend-jwt-with-mtls.yaml -n namespace-1
oc delete -f artifacts/backend-authenticate-mtls.yaml -n namespace-2
oc delete -f artifacts/frontend-authentication-mtls.yaml -n namespace-1
oc delete -f artifacts/frontend-destination-rule-mtls.yaml -n namespace-1
oc delete -f artifacts/frontend-jwt-with-mtls.yaml -n namespace-1
oc delete -f artifacts/egress-serviceentry.yml -n namespace-2
