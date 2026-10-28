variable "region" {
  description = "AWS region to build in"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voting-app"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m7i-flex.large"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}