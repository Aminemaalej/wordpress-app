variable "db_multi_az" {
  type        = bool
  description = "Whether to deploy to multi-az for RDS DB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_a_id" {
  type        = string
  description = "Subnet ID of Private Subnet A"
}

variable "private_subnet_b_id" {
  type        = string
  description = "Subnet ID of Private Subnet B"
}
