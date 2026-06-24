output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "fargate_pod_execution_role_arn" {
  description = "Fargate pod execution role ARN"
  value       = aws_iam_role.fargate_pod_execution_role.arn
}
