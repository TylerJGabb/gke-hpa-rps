resource "google_service_account" "stackdriver_adapter_agent" {
  account_id = "stackdriver-adapter-agent"
}

resource "google_project_iam_member" "stackdriver_adapter_agent_monitoring_viewer" {
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.stackdriver_adapter_agent.email}"
}

resource "google_service_account_iam_member" "stackdriver_adapter_agent_workload_identity_user" {
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.stackdriver_adapter_agent.id
  member             = "serviceAccount:${var.project}.svc.id.goog[custom-metrics/custom-metrics-stackdriver-adapter]"
}

output "stackdriver_adapter_agent_service_account" {
  value = google_service_account.stackdriver_adapter_agent.email
}
