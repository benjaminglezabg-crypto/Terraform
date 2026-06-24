terraform {
  backend "s3" {
    bucket  = "mi-terraform-state-bucket-test1"
    key     = "eks-test/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.8.0"
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------
# IAM role para el control plane de EKS
# ------------------------------------------------------------

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-cluster-role"
    Environment = "test"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ------------------------------------------------------------
# Cluster EKS
# ------------------------------------------------------------

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true

    public_access_cidrs = [
      var.eks_public_access_cidr
    ]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = var.cluster_name
    Environment = "test"
  }
}

# ------------------------------------------------------------
# IAM role de ejecución para los Pods en Fargate
# ------------------------------------------------------------

resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "${var.cluster_name}-fargate-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-fargate-pod-role"
    Environment = "test"
  }
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_policy" {
  role = aws_iam_role.fargate_pod_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# ------------------------------------------------------------
# Fargate profile para kube-system
# ------------------------------------------------------------

resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution_policy
  ]

  tags = {
    Name        = "${var.cluster_name}-kube-system"
    Environment = "test"
  }
}

# ------------------------------------------------------------
# Fargate profile para aplicaciones en namespace default
# ------------------------------------------------------------

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "default"
  }

  depends_on = [
    aws_eks_fargate_profile.kube_system
  ]

  tags = {
    Name        = "${var.cluster_name}-default"
    Environment = "test"
  }
}
