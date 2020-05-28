# Container Platform - Demo
<!-- TOC -->

- [Container Platform - Demo](#container-platform---demo)
  - [Create Namespaces, assign users and quotas](#create-namespaces-assign-users-and-quotas)
    - [RESTful API](#restful-api)
    - [CLI](#cli)
  - [Deploy Applications](#deploy-applications)
    - [Deploy user2 app](#deploy-user2-app)
    - [Deploy Frontend app](#deploy-frontend-app)
    - [Verify Installation](#verify-installation)
  - [Namespace's Quotas](#namespaces-quotas)
  - [Blue/Green and Canary Deployment](#bluegreen-and-canary-deployment)
    - [Frontend](#frontend)
      - [Blue/Green deployment](#bluegreen-deployment)
      - [Canary deployment](#canary-deployment)
    - [Backend](#backend)
      - [Blue/Green deployment](#bluegreen-deployment-1)
      - [Canary deployment](#canary-deployment-1)
  - [Horizontal Pod Autoscalers (HPA)](#horizontal-pod-autoscalers-hpa)
    - [by CPU](#by-cpu)
    - [by memory](#by-memory)
  - [East-West Security with Network Policy](#east-west-security-with-network-policy)
    - [Namespace: namespace-1](#namespace-namespace-1)
    - [Namespace: namespace-2](#namespace-namespace-2)
  - [North-South Security and control](#north-south-security-and-control)
    - [Ingress Traffic](#ingress-traffic)
    - [Egress Traffic](#egress-traffic)
  - [Log & Metrics and Monitoring](#log--metrics-and-monitoring)
    - [Developer Console](#developer-console)
    - [Monitoring Dashboard](#monitoring-dashboard)
    - [Operation and Application Log](#operation-and-application-log)
    - [Applications Metrics](#applications-metrics)
  - [Service Mesh](#service-mesh)
    - [Control Plane](#control-plane)
    - [Observability with Kiali and Jaeger](#observability-with-kiali-and-jaeger)
    - [Secure Backend by mTLS](#secure-backend-by-mtls)
    - [Secure frontend by JWT](#secure-frontend-by-jwt)
    - [Service Mesh Egress Policy](#service-mesh-egress-policy)
    - [Cleanup Istio](#cleanup-istio)

<!-- /TOC -->

![banner](images/OpenShiftContainerPlatform.png)

## Create Namespaces, assign users and quotas
- Create namespace for user1 and user2
  - user1 can edit namespace1 and namespace2
  - user2 can edit namespace3
- Assign quotas for all namespces

### RESTful API
- Get Token
```bash
TOKEN=$(oc whoami -t)
```
- Create project namespace-1
```bash
curl --verbose --insecure -location --request POST ${OCP}'/apis/project.openshift.io/v1/projectrequests' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer '${TOKEN} \
--data-raw '{
    "kind": "ProjectRequest",
    "apiVersion": "project.openshift.io/v1",
    "metadata": {
        "name": "namespace-1",
        "creationTimestamp": null
    },
    "displayName": "Namespace 1"
}'
```
- Label project namespace-1
```bash
curl --verbose --insecure --location --request PATCH ${OCP}'/api/v1/namespaces/namespace-1' \
--header 'Accept: application/json' \
--header 'Content-Type: application/merge-patch+json' \
--header 'Authorization: Bearer '${TOKEN} \
--data '{"metadata":{"labels":{"name":"namespace-1"}}}'
```
- Assign user1 with role **edit** to namespace-1 
```bash
curl --verbose --insecure --location --request POST ${OCP}'/apis/authorization.openshift.io/v1/namespaces/namespace-1/rolebindings' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer '${TOKEN} \
--data-raw '{
    "apiVersion": "authorization.openshift.io/v1",
    "kind": "RoleBinding",
    "metadata": {
        "name": "user1-edit-namespace-1",
        "namespace": "namespace-1"

    },
    "roleRef": {
        "apiGroup": "rbac.authorization.k8s.io",
        "kind": "ClusterRole",
        "name": "edit"
    },
    "subjects": [
        {
            "apiGroup": "rbac.authorization.k8s.io",
            "kind": "User",
            "name": "user1"
        }
    ]
}'
```
- Assign [size S quotas](artifacts/size-s-quotas.yaml) to namespace-1
```bash
curl --verbose --insecure --location --request POST ${OCP}'/api/v1/namespaces/namespace-1/resourcequotas' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer '${TOKEN} \
--data-raw '{
  "apiVersion": "v1",
  "kind": "ResourceQuota",
  "metadata": {
    "name": "size-s-quotas",
    "namespace": "namespace-1"
  },
  "spec": {
    "hard": {
      "pods": "15",
      "requests.cpu": "1",
      "requests.memory": "1Gi",
      "limits.cpu": "4",
      "limits.memory": "4Gi",
      "requests.storage": "3Gi"
    }
  }
}'
```

### CLI
- Create namespace-2 for user1 and namespace-3 for user2
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc new-project namespace-2 --display-name="Namespace 2"
oc label namespace namespace-2 name=namespace-2
oc new-project namespace-3 --display-name="Namespace 3"
oc label namespace namespace-3 name=namespace-3
oc policy add-role-to-user edit user1 -n namespace-2
oc policy add-role-to-user edit user2 -n namespace-3
```
- Assign [size S quotas](artifacts/size-s-quotas.yaml) to namespace-2 and namespace-3
```bash
oc apply -f artifacts/size-s-quotas.yaml -n namespace-2
oc apply -f artifacts/size-s-quotas.yaml -n namespace-3
```

## Deploy Applications

### Deploy user2 app
- Deploy dummy app by deployment config YAML file
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=user2
oc apply -f artifacts/dummy.yaml -n namespace-3
oc get pods -n namespace-3
```

### Deploy Frontend app
- Deploy frontend app with [frontend.yaml](artifacts/frontend.yaml) and [frontend-service.yaml](artifacts/frontend-service.yaml)
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=user1
oc apply -f artifacts/frontend.yaml -n namespace-1
oc apply -f artifacts/frontend-service.yaml -n namespace-1
oc create route edge frontend --service=frontend --port=8080 -n namespace-1
oc project namespace-1
watch oc get pods
echo "Front End URL=> https://$(oc get route frontend -o jsonpath='{.spec.host}' -n namespace-1)"
export FRONTEND_URL=https://$(oc get route frontend -o jsonpath='{.spec.host}' -n namespace-1)
```

<!-- - Deploy backend app
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=user1
oc apply -f artifacts/backend.yaml -n namespace-2
oc apply -f artifacts/backend-service.yaml -n namespace-2
echo "Backend Internal End URL=> http://$(oc get svc backend  -o jsonpath='{.spec.ports[0].port}'  -n namespace-2)" 
```-->

### Deploy Backend app (Helm Chart)
- Deploy backend app using helm chart => [backend-chart](backend-chart)
- Test with dry run 
```bash
oc project -n namespace-2
helm install --dry-run test ./backend-chart
```
- Install chart
```bash
oc project -n namespace-2
helm install backend-v1 ./backend-chart
#Sample Output
NAME: backend-v1
LAST DEPLOYED: Mon May 18 10:33:26 2020
NAMESPACE: namespace-2
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
http://backend:8080
```
- Check Helm Chart in Developer Console Topology view

![Helm Topology](images/developer-console-helm-topology.png )

- Helm Chart details

![Helm Chart](images/developer-console-helm-chart.png)

### Verify Installation
- Check pods on namespace-1 and namespace-2
```bash
oc get pods -n namespace-1
#Sample output
NAME                READY   STATUS      RESTARTS   AGE
frontend-1-b2w7p    1/1     Running     0          8m37s
frontend-1-deploy   0/1     Completed   0          8m34s
oc get pods -n namespace-2
#Sample output
NAME               READY   STATUS      RESTARTS   AGE
backend-1-deploy   0/1     Completed   0          5s
backend-1-pdkf9    1/1     Running     0          8s
```

- Check Develor Console for applications's configuration

![frontend app](images/frontend-app.png)

![backend app](images/backend-app.png)
  
## Namespace's Quotas
- Check Namespace's quotas on Project Details on Web Developer Console

![project details - resources quota](images/project-details-resource-quotas.png)

- Drill down to Resource Quota details view

![resource quota details](images/resource-quota-details.png)

- Scale pod to 8
```bash
oc scale dc/backend --replicas=8 -n namespace-2
#Or use developer console
```
- Check Web Console for namespace-2 resource quotas.

![namespace-2 8 pods](images/namespace-2-8-pods.png)

- Create 3 more pods. This will exceeded quota's of request CPU and memory.

![namesapce-2 11 pods](images/namespace-2-11-pods.png)

- Check alert in event viewer.

![quota exceeded alert](images/quota-exceeded-alert.png)
)
- Apply [size M](artifacts/size-m-quotas.yaml) 
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc apply -f artifacts/size-m-quotas.yaml -n namespace-2
oc delete -f artifacts/size-s-quotas.yaml -n namespace-2
```
- Check Web Console for namespace-2 resource quotas. CPU request will be 50% used.

![namespace-2 11 pods with size M](images/namespace-2-size-m-11-pods.png)

- Scale to 12 pods and check number of backend pods on namespace-2
```bash
oc scale dc/backend --replicas=12 -n namespace-2
oc get pods -n namespace-2 | grep backend | grep Running | wc -l
```

- Reapply [size S](artifacts/size-s-quotas.yaml) and check resource quotas
```bash
oc apply -f artifacts/size-s-quotas.yaml -n namespace-2
oc delete -f artifacts/size-m-quotas.yaml -n namespace-2
```
Utilization

![namespace-2 exceeded quotas](images/namespace-2-exceeded-quotas.png)

- Scale backend pod to 1 and claim storage for 2 GB
```bash
oc project namespace-2
oc scale dc/backend --replicas=1 -n namespace-2
watch oc get pods
oc set volume dc/backend --add --name=data --type=persistentVolumeClaim --claim-name=data \
--claim-size=2Gi --claim-mode='ReadWriteOnce' --mount-path=/data --containers=backend -n namespace-2
watch oc get pods
```
- Check PVC claim
```bash
oc get pvc -n namespace-2
#Sample Output
NAME   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data   Bound    pvc-08d07d60-b240-4b6d-94b1-a2d5df1b9203   2Gi        RWO            gp2            7m17s
```
- Check mounted file system pod
```bash
oc exec $(oc get pods -n namespace-2 | grep backend | grep Running | head -n 1 | awk '{print $1}') -- df -m
#Sample Output
Filesystem                           1M-blocks  Used Available Use% Mounted on
overlay                                 122341 15081    107261  13% /
tmpfs                                       64     0        64   0% /dev
tmpfs                                    31474     0     31474   0% /sys/fs/cgroup
shm                                         64     1        64   1% /dev/shm
tmpfs                                    31474     6     31468   1% /etc/passwd
/dev/nvme2n1                              1952     6      1930   1% /data
/dev/mapper/coreos-luks-root-nocrypt    122341 15081    107261  13% /etc/hosts
tmpfs                                    31474     1     31474   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                                    31474     0     31474   0% /proc/acpi
tmpfs                                    31474     0     31474   0% /proc/scsi
tmpfs                                    31474     0     31474   0% /sys/firmware
```
- Check Web Console for namespace-2 resource quotas.

![namespace-2 storage quotas](images/namespace-2-storage-quotas.png)

- Create new deployment ([dummy-with-pvc.yaml](artifacts/dummy-with-pvc.yaml)) with 2 GB persistent volume claim
```bash
oc apply -f artifacts/dummy.yaml -n namespace-2
oc set volume dc/dummy --add --name=data --type=persistentVolumeClaim --claim-name=data2 \
--claim-size=2Gi --claim-mode='ReadWriteOnce' --mount-path=/data --containers=dummy -n namespace-2
```
- Persistent volume claim will faied because quota is 3 GB
```bash
error: failed to patch volume update to pod template: persistentvolumeclaims "data2" is forbidden: exceeded quota: size-s-quotas, requested: requests.storage=2Gi, used: requests.storage=2Gi, limited: requests.storage=3Gi
```
- Remove persistent volume claim from backend and delete dummy deployment.
```bash
oc set volume dc/backend --remove --name=data -n namespace-2
oc delete pvc data -n namespace-2
oc delete -f artifacts/dummy.yaml -n namespace-2
```

## Blue/Green and Canary Deployment

### Frontend

#### Blue/Green deployment
- deploy [frontend-v2](artifacts/frontend-v2.yaml) on namespace-1
```bash
oc apply -f artifacts/frontend-v2.yaml -n namespace-1
oc expose dc/frontend-v2 -n namespace-1
oc project namespace-1
watch oc get pods
```
- Check Developer Console

![Developer Console Frontend Project](images/developer-console-blue-green.png)

- Run test script to frontend route
```bash
scripts/loop-frontend.sh
```
- Sample output
```log
Loop: 1
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
Loop: 2
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
Loop: 3
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
```
- Blue/Green deployment by configure frontend route to switch to frontend-v2 ( on another terminal)
```bash
scripts/blue-green-deployment.sh
```
- [blue-green-deployment.sh](blue-green-deployment.sh) configure route to point to service frontend-v2
```bash
#Change target service to frontend-v2
oc patch route frontend  -p '{"spec":{"to":{"name":"'frontend-v2'"}}}' -n namespace-1
#Check route configuration
oc describe route rontend -n namespace-1
#Sample output
...
Service:	frontend
Weight:		100 (100%)
```

<!-- Check Developer Console that route is point to frontend-v2

![Developer Console Frontend Project](images/developer-console-blue-green-v2.png) -->

- Check Result
```log
Loop: 3
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
Loop: 4
Frontend version: v2 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
Loop: 5
Frontend version: v2 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-srrhl, Status:200, Message: Hello, World]
```
- Switch back to v1
```bash
oc patch route frontend  -p '{"spec":{"to":{"name":"'frontend'"}}}' -n namespace-1
```

#### Canary deployment
- Canary deployment with 80% of request to v1 and 20% to v2 with [frontend-route-canary-80-20.yaml](artifacts/frontend-route-canary-80-20.yaml)
```bash
oc apply -f artifacts/frontend-route-canary-80-20.yaml -n namespace-1
```
- Test canary deployment with [frontend-loop-10.sh](scripts/loop-frontend-10.sh)
```bash
scripts/loop-frontend-10.sh
#Output
Frontend: v1
Frontend: v1
Frontend: v1
Frontend: v1
Frontend: v2
Frontend: v1
Frontend: v1
Frontend: v1
Frontend: v1
Frontend: v2
========================================================
Version v1: 8
Version v2: 2
========================================================
```
- Adjust weight to 70/30 with [frontend-route-canary-70-30.yaml](artifacts/frontend-route-canary-70-30.yaml)
```bash
oc apply -f artifacts/frontend-route-canary-70-30.yaml -n namespace-1
#Output
Frontend: v1
Frontend: v1
Frontend: v1
Frontend: v2
Frontend: v1
Frontend: v1
Frontend: v2
Frontend: v1
Frontend: v1
Frontend: v2
========================================================
Version v1: 7
Version v2: 3
========================================================
```
- Remove frontend-v2 and configure route to v1 only
```bash
oc apply -f artifacts/frontend-route.yaml -n namespace-1
oc delete dc/frontend-v2;oc delete svc/frontend-v2
```

### Backend

#### Blue/Green deployment

- deploy [backend-v2](artifacts/backend-v2.yaml) on namespace-2
```bash
oc apply -f artifacts/backend-v2.yaml -n namespace-2
```
- Run test script to frontend route
```bash
scripts/loop-frontend.sh
```
- Sample output
```log
Loop: 1
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-72vtd, Status:200, Message: Hello, World]
Loop: 2
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-72vtd, Status:200, Message: Hello, World]
Loop: 3
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-72vtd, Status:200, Message: Hello, World]
```
- Blue/Green deployment for backend by configure backend service selector to select label version v2
```bash
oc patch service backend  -p '{"spec":{"selector":{"version":"'v2'"}}}' -n namespace-2
```
- Check output on anther terminal that backend is witch to v2
- Switch back to v1
```bash
oc patch service backend  -p '{"spec":{"selector":{"version":"'v1'"}}}' -n namespace-2
```
- Remove [backend-v2](artifacts/backend-v2.yaml) 
```bash
oc delete -f artifacts/backend-v2.yaml -n namespace-2
```

#### Canary deployment
Canary deployment for service is supported by Serverless or Service Mesh. Following steps demonstrate for Serverless

- Deploy backend with Serverless
```bash
kn service create backend --namespace namespace-2 --revision-name=backend-v1 --image quay.io/voravitl/backend-native:v1
```
- Test
```bash

```

## Horizontal Pod Autoscalers (HPA)

### by CPU
- Set HPA for frontend app based on CPU utilization.
```bash
oc autoscale dc/frontend --min 1 --max 3 --cpu-percent=3 -n namespace-1
```
- Check HPA status and load test to drive CPU workload
```bash
watch oc get hpa -n namespace-1
#Run load test on another terminal
siege -c 20 https://$(oc get route frontend -o jsonpath='{.spec.host}' -n namespace-1)
#Check number of pods on another terminal
oc describe PodMetrics <pod name>  -n namespace-1
```

### by memory
- Set HPA for backend based on memory utilization with 60 MB threshold
```bash
oc apply -f artifacts/backend-memory-hpa.yaml -n namespace-2
```
- Check HPA status and load test
```bash
watch oc get hpa -n namespace-2
#Run load test on another terminal
siege -c 20 https://$(oc get route frontend -o jsonpath='{.spec.host}' -n namespace-1)
oc describe
```
- Clean up HPA configuration
```bash
oc delete hpa --all -n namespace-1
oc delete hpa --all -n namespace-2
```
<!-- ### by custom metrics -->



## East-West Security with Network Policy

### Namespace: namespace-1

Frontend App in namespace namespace-1 accept only request from OpenShift's router in namespace openshift-ingress by apply policy [deny all](artifacts/network-policy-deny-from-all.yaml) and [accept from ingress](artifacts/network-policy-allow-network-policy-global.yaml)

- Default network policy
```bash
oc get networkpolicy -n namespace-1
#Output
NAME                           POD-SELECTOR   AGE
allow-from-all-namespaces      <none>         152m
allow-from-ingress-namespace   <none>         152m
```
- Remove allow-from-all-namespaces from namespace-1
```bash
oc delete networkpolicy/allow-from-ingress-namespace -n namespace-1
```
<!-- - Apply network policy to default with [network-policy-deny-from-all.yaml](artifacts/network-policy-deny-from-all.yaml)
```bash
oc apply -f artifacts/network-policy-deny-from-all.yaml -n namespace-1
oc apply -f artifacts/allow-network-policy-global.yaml -n namespace-1
```
- Sample of apply network policy by RESTful API
```bash
TOKEN=$(oc whoami -t)
curl --verbose --insecure --location --request POST ${OCP}'/apis/networking.k8s.io/v1/namespaces/namespace-1/networkpolicies' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer '${TOKEN} \
--data-raw '{
    "apiVersion": "networking.k8s.io/v1",
    "kind": "NetworkPolicy",
    "metadata": {
        "name": "deny-from-all"    },
    "spec": {
        "podSelector": {},
        "policyTypes": [
            "Ingress"
        ]
    }
}'
curl --verbose --insecure --location --request POST ${OCP}'/apis/networking.k8s.io/v1/namespaces/namespace-1/networkpolicies' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer '${TOKEN} \
--data-raw '{
  "apiVersion": "networking.k8s.io/v1",
  "kind": "NetworkPolicy",
  "metadata": {
    "name": "allow-network-policy-global"
  },
  "spec": {
    "podSelector": {},
    "ingress": [
      {
        "from": [
          {
            "namespaceSelector": {
              "matchLabels": {
                "network-policy": "global"
              }
            }
          }
        ]
      }
    ],
    "policyTypes": [
      "Ingress"
    ]
  }
}' -->
- Check network policy on namespace-1
```bash
oc get networkpolicy -n namespace-1

# Output
NAME                          POD-SELECTOR   AGE
allow-network-policy-global   <none>         8s
```
- Check that route still work properly
```bash
curl -v $FRONTEND_URL/version
```
- Pod in namespace-1 can connect ot service in namespace-1
```bash
oc exec $(oc get pods -n namespace-1 | grep Running | head -n 1 | awk '{print $1}') -n namespace-1 -- curl http://frontend.namespace-1.svc.cluster.local:8080/version

# Output
Frontend version:v1, Response:200, Meessage:check version
```
- Pod in namespace-2 cannot connect to pod on namespace-1
```bash
oc exec $(oc get pods -n namespace-2 | grep Running | head -n 1 | awk '{print $1}') -n namespace-2 -- curl http://frontend.namespace-1.svc.cluster.local:8080/version

# Output
Connection timed out command terminated with exit code 7
```

### Namespace: namespace-2

Backend App in namespace namespace-2 accept only request from namespace-1 and pods must contains label app=frontend remove default allow-from-all-namespaces.

- Configure network policies for namespace-2
```bash
oc delete networkpolicy/allow-from-all-namespaces -n namespace-2
oc apply -f artifacts/network-policy-allow-from-namespace-1.yaml -n namespace-2
```
- Check network policy
```bash
oc get networkpolicy -n namespace-2

# Output
NAME                           POD-SELECTOR   AGE
allow-from-ingress-namespace   <none>         27m
allow-from-namespace-1         app=backend    5s
```

- Pod in namespace-1 can connect to pod on namespace-2
```bash
oc exec $(oc get pods -n namespace-1 | grep Running | head -n 1 | awk '{print $1}') -n namespace-1 -- curl http://backend.namespace-2.svc.cluster.local:8080/version
```
- Check that route still work properly.
```bash
curl -v $FRONTEND_URL
```
- Expose route for backend service
```
oc expose svc/backend -n namespace-2
BACKEND_URL=http://$(oc get route backend -n namespace-2 -o jsonpath='{.spec.host}')
curl -v ${BACKEND_URL}/version
```
- Project namespace-2 is used for backend service only. Then remove allow-from-ingress-namespace and test backend's route again.
```bash
oc delete networkpolicy/allow-from-ingress-namespace -n namespace-2
curl -v ${BACKEND_URL}/version
```
- Delete backend's route
```bash
oc delete route/backend -n namespace-2
```

## North-South Security and control

### Ingress Traffic
- For ingress traffic, set rate limits for http protocol to 5 for each IP
```bash
oc annotate route frontend haproxy.router.openshift.io/rate-limit-connections=true -n namespace-1
oc annotate route frontend haproxy.router.openshift.io/rate-limit-connections.rate-http=5 -n namespace-1
```
- Test with [loop-frontend.sh](scripts/loop-frontend.sh)
```bash
...
Loop: 4
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-6gzdw, Status:200, Message: Hello, World]
Loop: 5
Frontend version: v1 => [Backend: http://backend.namespace-2.svc.cluster.local:8080, Response: 200, Body: Backend version:v1, Response:200, Host:backend-1-6gzdw, Status:200, Message: Hello, World]
Loop: 6
curl: (52) Empty reply from server
...
```
- For ingress traffic, IP whitelist can be set to each route.
```bash
oc annotate route frontend haproxy.router.openshift.io/ip_whitelist=13.52.0.0/16 -n namespace-1
```
- Test with cURL
```bash
curl $FRONTEND_URL

# Output
curl: (52) Empty reply from server
```
- Annotate route with test's IP address
```bash
oc annotate route frontend haproxy.router.openshift.io/ip_whitelist=$(curl http://ident.me) --overwrite -n namespace-1
```
- Test with cURL again and remove IP whitelist
```bash
curl $FRONTEND_URL
oc annotate route frontend haproxy.router.openshift.io/ip_whitelist= --overwrite -n namespace-1
```
### Egress Traffic
- Configure egress filrewall to allow only destination is facebook.com
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc apply -f artifacts/egress-namespace-2-facebook.yaml -n namespace-2
curl $FRONTEND_URL

# Output
<html><body><h1>504 Gateway Time-out</h1>
The server didn't respond in time.
</body></html>
```
- For egress traffic, set [egress firewall](artifacts/egress-namespace-2.yaml) to allow only [httpbin.org](https://httpbin.org)
```bash
oc delete egressnetworkpolicy/egress-namespace-2 -n namespace-2
oc apply -f artifacts/egress-namespace-2.yaml -n namespace-2
curl $FRONTEND_URL
```
- Remove egress 
```bash
oc delete egressnetworkpolicy/egress-namespace-2 -n namespace-2
```

## Log & Metrics and Monitoring

### Developer Console

Users can use developer console to monitor metrics data from Prometheus, view graph with builtin Grafana and Events with alert manager.

- Overall Namespace Utilization

![Namespace Utilization](images/developer-console-namespace-utilization.png)

- Namespace Monitoring

![Namespace Monitoring](images/developer-console-monitoring.png)

- Metrics Data

![Metriics](images/developer-console-metrics.png)

- Namespace Events

![Namespace Events](images/developer-console-events.png)

### Monitoring Dashboard

Monitoring dashboard for Administrator and Operator


### Operation and Application Log
- WIP





### Applications Metrics
- Create namespace for Prometheus and Grafana
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc new-project user1-app-monitor --display-name="User1 - application monitor"
oc label namespace user1-app-monitor role=app-monitor
```
- Set network policy for namespace-2 to allow traffic from user1-app-monitor
```bash
oc apply -f artifacts/network-policy-allow-from-app-monitor.yaml -n namespace-2
```
- Setup Promethues in namespace user1-app-monitor by crete CRD resources
```bash

# Service Account steps need cluster admin roles.
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc apply -f artifacts/prometheus-service-account.yaml -n user1-app-monitor
oc login --insecure-skip-tls-verify=true --server=$OCP --username=usr1
oc apply -f artifacts/prometheus-service-monitor.yaml -n user1-app-monitor
oc apply -f artifacts/prometheus.yaml -n user1-app-monitor
oc create route edge prometheus --service=prometheus --port=9090 -n user1-app-monitor
echo "https://$(oc get route prometheus -n user1-app-monitor -o jsonpath='{.spec.host}')"
```
- Setup Grafana in namespace user1-app-monitor by crete CRD resources
```bash
oc apply -f artifacts/grafana_datasource.yaml -n user1-app-monitor
oc apply -f artifacts/grafana.yaml -n user1-app-monitor
oc apply -f artifacts/grafana_dashboard.yaml -n user1-app-monitor
echo "https://$(oc get route grafana-route -n user1-app-monitor -o jsonpath='{.spec.host}')"
```
- Check Prometheus and Granfana on Developer Console

![prometheus and grafana](images/prometheus-and-grafana-dev-console.png)

- Check prometheus console for Target and test query

![prometheus target](images/prometheus-target.png)

- Grafana Dashboard

![granfana](images/grafana.png)

## Service Mesh

### Control Plane
- Create namespace for control plane
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc new-project user1-istio-system --display-name="Service Mesh Control Plane for user1"

# oc label namespace user1-istio-system network-policy=istio-system
oc policy add-role-to-user edit user1 -n user1-istio-system

# operator automatic crate network policy - double check again!

# oc apply -f artifacts/network-poliy-allow-from-istio-system.yaml -n namespace-1

# oc apply -f artifacts/network-poliy-allow-from-istio-system.yaml -n namespace-2
```
- Use cluster admin user to install following operators
  - ElasticSearch
  - Jaeger
  - Kibana
  - OpenShift Service Mesh
- Create control plane and join namespace-1 and namespace-2 to control plane
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=user1
oc apply -f artifacts/service-mesh-basic-install.yaml -n user1-istio-system
oc project user1-istio-system
watch oc get pods
oc apply -f artifacts/service-mesh-memberroll.yaml -n user1-istio-system
```
- Check network policy for namespace-1
```bash
oc get networkpolicy -n namespace-1

# Output
NAME                     POD-SELECTOR                   AGE
allow-from-namespace-1   app=backend                    6h19m
istio-expose-route       maistra.io/expose-route=true   18s
istio-mesh               <none>                         18s
```
- Inject sidecar by annotate sidecar.istio.io/inject to deployment config template.
```bash
oc patch dc frontend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n namespace-1
oc patch dc backend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n namespace-2
```
- Check that sidecar is injected to pod
```
oc get pods -n namespace-1
oc get pods -n namespace-2
```
### Observability with Kiali and Jaeger
- Run load test tool
```bash
siege -c 5 https://$(oc get route frontend -o jsonpath='{.spec.host}' -n namespace-1)
```
- Kiali graph displays application topology
  
  ![kiali graph](images/kiali-graph.png)

- Jaeger trasaction tracing
  
  ![Jaeger](images/jaeger.png)

### Secure Backend by mTLS
- Enable mTLS for backend by create destination rule and virtual service.
```bash
oc patch dc frontend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/rewriteAppHTTPProbers":"true"}}}}}' -n namespace-1
oc patch dc backend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/rewriteAppHTTPProbers":"true"}}}}}' -n namespace-2
oc apply -f artifacts/backend-destination-rule.yaml -n namespace-2
oc apply -f artifacts/backend-virtual-service.yaml -n namespace-2
oc apply -f artifacts/backend-authenticate-mtls.yaml -n namespace-2
```
- Create [dummy pod](artifacts/dummy.yaml) (without sidecar) on namespace-1 
```bash
oc apply -f artifacts/dummy.yaml -n namespace-1
```
- Connect ot dummy pod terminal and cURL to backend service
```bash
oc exec $(oc get pods -n namespace-1 | grep dummy | grep Running | head -n 1 | awk '{print $1}') -n namespace-1 -- curl http://backend.namespace-2.svc.cluster.local:8080
```
- Following error will be displayed
```bash
curl: (56) Recv failure: Connection reset by peer
```
- Connect to frontend pod terminal and cURL to backend service.
```bash
oc exec -c frontend $(oc get pods -n namespace-1 | grep frontend | grep Running | head -n 1 | awk '{print $1}') -n namespace-1 -- curl http://backend.namespace-2.svc.cluster.local:8080
```
- cURL to frontend's route to verify that route still working properly.

### Secure frontend by JWT
- Create [destination rule](artifacts/frontend-destination-rule.yaml), [gateway](artifacts/frontend-gateway.yaml) and [virtual service](artifacts/frontend-virtual-service.yaml) for frontend
```bash
oc apply -f artifacts/frontend-destination-rule.yaml -n namespace-1
oc apply -f artifacts/frontend-gateway.yaml -n namespace-1
oc apply -f artifacts/frontend-virtual-service.yaml -n namespace-1
echo "Istio Gateway URL=> https://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user1-istio-system)"
```
- Enable [JWT authorization](artifacts/frontend-jwt-with-mtls.yaml) for frontend
```bash
oc apply -f artifacts/frontend-jwt-with-mtls.yaml -n namespace-1
```
- Check generated token with [jwt.io](https://jwt.io)
- Test without JWT token, wrong JWT token and valid JWT token
```bash
curl -v http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user1-istio-system)

# Unauthorized

# Origin authentication failed
curl -v -H "Authorization: Bearer $(cat artifacts/jwt-wrong-realms.txt)" http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user1-istio-system)

# Unauthorized

# Origin authentication failed
curl -v -H "Authorization: Bearer $(cat artifacts/token.txt)" http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user1-istio-system)

# Success
```

### Service Mesh Egress Policy
<!-- - Remove egress firewall
```bash
oc login --insecure-skip-tls-verify=true --server=$OCP --username=opentlc-mgr
oc delete -f artifacts/egress-namespace-2.yaml -n namespace-2
``` -->
- Set control plane configuration to disallow egress traffic by default
```bash
 oc get configmap istio -n user1-istio-system -o yaml \
  | sed 's/mode: ALLOW_ANY/mode: REGISTRY_ONLY/g' \
  | oc replace -n user1-istio-system -f -
```
- Create [egerss service entry](artifacts/egress-serviceentry.yml) to allow https request to httpbin.org
```bash
oc apply -f artifacts/egress-serviceentry.yml -n user1-istio-system
```
- Check kiali graph

![egress service entry](images/kiali-egress-service-entry.png)

- Set control plane to ALLOW_ANY
```bash
 oc get configmap istio -n user1-istio-system -o yaml \
  | sed 's/mode: REGISTRY_ONLY/mode: ALLOW_ANY/g' \
  | oc replace -n user1-istio-system -f -
```

### Cleanup Istio
- Remove sidecar
```bash
oc patch dc frontend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"false"}}}}}' -n namespace-1
oc patch dc backend -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"false"}}}}}' -n namespace-2
```
- [Remove configurations](scripts/remove-all-istios.sh)
```bash
scripts/remove-all-istios.sh
```
