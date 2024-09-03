variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_a_id" {
  type        = string
  description = "Subnet ID of Public Subnet A"
}

variable "public_subnet_b_id" {
  type        = string
  description = "Subnet ID of Public Subnet B"
}

variable "private_subnet_a_id" {
  type        = string
  description = "Subnet ID of Private Subnet A"
}

variable "private_subnet_b_id" {
  type        = string
  description = "Subnet ID of Private Subnet B"
}

variable "db_security_group" {
  type        = string
  description = "wordpress-db Security Group ID"
}

variable "asg_desired_capacity" {
  type        = number
  description = "EC2 Autoscaling Group desired capacity"
}

variable "asg_min_size" {
  type        = number
  description = "EC2 Autoscaling Group minimum size"
}

variable "asg_max_size" {
  type        = number
  description = "EC2 Autoscaling Group maximum size"
}
