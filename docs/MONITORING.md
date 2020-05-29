# Monitoring Tools
<!-- TOC -->

- [Monitoring Tools](#monitoring-tools)
  - [Developer Console](#developer-console)
  - [Monitoring Dashboard](#monitoring-dashboard)
  - [Operation and Application Log](#operation-and-application-log)
  - [Applications Metrics](#applications-metrics)

<!-- /TOC -->

## Developer Console

Users can use developer console to monitor metrics data from Prometheus, view graph with builtin Grafana and Events with alert manager.

- Overall Namespace Utilization

![Namespace Utilization](images/developer-console-namespace-utilization.png)

- Namespace Monitoring

![Namespace Monitoring](images/developer-console-monitoring.png)

- Metrics Data

![Metriics](images/developer-console-metrics.png)

- Namespace Events

![Namespace Events](images/developer-console-events.png)

## Monitoring Dashboard

Monitoring dashboard for Administrator and Operator

- Compute resources by Cluster

![cluster](images/grafana-cluster.png)


- Compute resources by Node

![node](images/grafana-node.png)

## Operation and Application Log

OpenShift builtin with EFK stack. Kibana will use RBAC from OpenShift then each user will access only their namespace.

- Login to Kibana with user1

![log](images/kibana-rbac.png)

- Overall log

![log](images/kibana-elasticsearch-log.png)

- Login to Kibana with Cluster Admin to check operator

![log](images/kibana-operator.png)

## Applications Metrics
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
