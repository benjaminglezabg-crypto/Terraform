terraform {
  backend "s3" {
    bucket = "mi-terraform-state-bucket-test1"
    key    = "ec2-test/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-test-sg-1"
  description = "Allow SSH access"
  vpc_id      = "vpc-0b501d57c8b31ebe3"

  tags = {
    Name = "ec2-test-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_my_ip" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "177.249.175.66/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Allow SSH from my IP"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "test_ec2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-063d07d493700917c"
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = "new"

  tags = {
    Name = "ec2-test-terraform"
  }
}

output "public_ip" {
  value = aws_instance.test_ec2.public_ip
}

output "private_ip" {
  value = aws_instance.test_ec2.private_ip
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}
