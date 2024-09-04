variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}