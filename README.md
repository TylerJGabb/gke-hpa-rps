# Controlling HPA with load balancer RPS

## TODO
The HPA currently hard codes the name of the `resource.labels.backend_name: k8s1-2908a40f-default-hostname-80-a795fcc0` and this should be parameterized in some way. I'm wondering, how can we get the name of the backend service without needing to know it ahead of time?

The fields available on the metric are as follows, and I don't see anything that can be directly correlated with values that are known within the context of the manifests that are being deployed.

```json
{
  "kind": "ExternalMetricValueList",
  "apiVersion": "external.metrics.k8s.io/v1beta1",
  "metadata": {},
  "items": [
    {
      "metricName": "loadbalancing.googleapis.com|https|internal|request_count",
      "metricLabels": {
        "metric.labels.cache_result": "DISABLED",
        "metric.labels.protocol": "HTTP/1.1",
        "metric.labels.response_code": "200",
        "metric.labels.response_code_class": "200",
        "resource.labels.backend_name": "k8s1-2908a40f-default-hostname-80-a795fcc0",
        "resource.labels.backend_scope": "us-central1-a",
        "resource.labels.backend_scope_type": "ZONE",
        "resource.labels.backend_target_name": "k8s1-2908a40f-default-hostname-80-a795fcc0",
        "resource.labels.backend_target_type": "BACKEND_SERVICE",
        "resource.labels.backend_type": "NETWORK_ENDPOINT_GROUP",
        "resource.labels.forwarding_rule_name": "k8s2-fr-7y8d4tvm-default-ilb-demo-ingress-1bi42yf3",
        "resource.labels.matched_url_path_rule": "UNMATCHED",
        "resource.labels.network_name": "tf-network",
        "resource.labels.project_id": "gke-sandbox-421603",
        "resource.labels.region": "us-central1",
        "resource.labels.target_proxy_name": "k8s2-tp-7y8d4tvm-default-ilb-demo-ingress-1bi42yf3",
        "resource.labels.url_map_name": "URL_MAP/948092892916_k8s2-um-7y8d4tvm-default-ilb-demo-ingress-1bi42yf3",
        "resource.type": "internal_http_lb_rule"
      },
      "timestamp": "2024-04-29T02:02:02Z",
      "value": "500m"
    }
  ]
}
```

Some Ideas:

- can we add some annotations to the ingress object? would those then appear in the metric?
- can we optimistically expect the ingress to be in the same namespace as the HPA and then query the API for the ingress object, with some obvious field like `"metric.labels.response_code": "200"`


## Step 1 (terraform seed)
Apply the terraform configuration to create the resources in the cloud.

## Step 2 (make sure the cluster is running ant internal load balancers can be created)
Install the following manifests into the cluster to audit load balancer creation with ingress
- [internal-ing.yaml](./manifests/internal-ing.yaml) 
- [web-deploy-yaml](./manifests/web-deploy.yaml)
- [web-svc.yaml](./manifests/web-svc.yaml)

## Step 3 (custom metrics adapter)
Install the custom-metrics-stackdriver-#dapter onto the cluster, this involves severla steps
1. `curl https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml > custom-metrics-stackdriver-adapter.yaml`
2. Add the `--enable-distribution-support=true` flag to the `args` field in the `custom-metrics-stackdriver-adapter.yaml` file
3. `kubectl apply -f custom-metrics-stackdriver-adapter.yaml`
4. Make sure metrics are available by running `kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .`

## Step 4 (create the HPA)
1. `kubectl apply -f hpa-rps.yaml`

## Step 5 (create the load test)
1. ssh into the vm and start some curl request loops to stress the load balancer
2. slowly add more and more requests to the load balancer to see the HPA scale up the pods
![alt text](rps-vs-hpa.png)

### A note about how scaling works
The HPA is utilizing the `AverageValue` so the ratio used to scale is the found via the calculation `((currentValue / currentReplicas) / targetValue)` and then that is compared againsed the `targetValue` to determine if the HPA should scale up or down.

#### For Example
- Let `RPS = 2` 
- Let `currentTeplicas=1`
- Let `targetValue=1`

Then the ratio is is `(2/1)/1 = 2`, triggering a scale up, by 1 pods, from `1 -> 2`

Once the pods are scaled up, then the ratio is `(2/2)/1 = 1`, which is equal to our target value, so the HPA will not scale anymore.

