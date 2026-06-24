variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "mi-eks-fargate"
}

variable "subnet_ids" {
  description = "Subnets used by the EKS control plane"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "EKS requires at least two subnets in different Availability Zones."
  }
}

variable "private_subnet_ids" {
  description = "Private subnets used by EKS Fargate"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Provide at least two private subnets."
  }
}

variable "eks_public_access_cidr" {
  description = "CIDR allowed to access the public EKS API endpoint"
  type        = string
}
