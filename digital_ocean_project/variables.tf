variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "k8s_region" {
  description = "DigitalOcean region for the Kubernetes cluster"
  type        = string
  default     = "nyc1"
}
