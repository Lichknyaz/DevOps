variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets used by the EKS control plane"
}

variable "node_subnet_ids" {
  type        = list(string)
  description = "Subnets used by the managed node group"
}

variable "node_group_name" {
  type        = string
  description = "Name for the managed node group"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for worker nodes"
}

variable "node_min_size" {
  type        = number
  description = "Minimum size of the node group"
}

variable "node_max_size" {
  type        = number
  description = "Maximum size of the node group"
}

variable "node_desired_size" {
  type        = number
  description = "Desired size of the node group"
}

variable "endpoint_public_access" {
  type        = bool
  description = "Expose the EKS API endpoint publicly"
}

variable "endpoint_private_access" {
  type        = bool
  description = "Expose the EKS API endpoint privately inside the VPC"
}
