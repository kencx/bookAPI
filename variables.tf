variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t2.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  type        = string
  description = "Private subnet CIDR block"
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_block_secondary" {
  type        = string
  description = "Private subnet CIDR block (secondary)"
  default     = "10.0.3.0/24"
}

variable "public_ingress_ports" {
  type        = list(number)
  description = "List of public ingress ports"
  default     = [22, 80, 443]
}
