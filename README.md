# Step 1 (terraform seed)
Apply the terraform configuration to create the resources in the cloud.

# Step 2 (k8s seed)
Install the following manifests into the cluster to audit load balancer creation with ingress
- [internal-ing.yaml](./manifests/internal-ing.yaml) 
- [web-deploy-yaml](./manifests/web-deploy.yaml)
- [web-svc.yaml](./manifests/web-svc.yaml)

# Step 3 (custom metrics adapter)
Install the custom-metrics-stackdriver-#dapter onto the cluster, this involves severla steps
1. `curl https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml > custom-metrics-stackdriver-adapter.yaml`
2. Add the `--enable-distribution-support=true` flag to the `args` field in the `custom-metrics-stackdriver-adapter.yaml` file
3. `kubectl apply -f custom-metrics-stackdriver-adapter.yaml`


