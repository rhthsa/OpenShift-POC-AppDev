# Horizontal Pod Autoscaler (HPA)
<!-- TOC -->

- [Horizontal Pod Autoscaler (HPA)](#horizontal-pod-autoscaler-hpa)
  - [HPA by CPU](#hpa-by-cpu)
  - [HPA by Memory](#hpa-by-memory)

<!-- /TOC -->

## HPA by CPU
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

## HPA by Memory
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

