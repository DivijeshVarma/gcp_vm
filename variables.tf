variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "gcp_service_list" {
  type        = list(string)
  description = "List of GCP APIs to enable"
}