variable "project_id" {
  description = "advance-engine-444818-p0"
}

variable "region" {
  description = "asia-northeast3"
}

variable "gke_num_nodes" {
  default     = 3
  description = "Number of GKE nodes"
}

variable "gke_machine_type" {
  default     = "n1-standard-4"
  description = "Machine type for GKE nodes"
}

