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

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "eks_public_access_cidr" {
  description = "CIDR permitted to access the public EKS API endpoint"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.eks_public_access_cidr))
    error_message = "eks_public_access_cidr must be a valid CIDR, such as 177.249.175.66/32."
  }
}
