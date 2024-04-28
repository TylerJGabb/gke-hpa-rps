kubectl annotate serviceaccount --namespace custom-metrics \
  custom-metrics-stackdriver-adapter \
  iam.gke.io/gcp-service-account=stackdriver-adapter-agent@gke-sandbox-421603.iam.gserviceaccount.com