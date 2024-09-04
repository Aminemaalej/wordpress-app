variable "aws_region" {
  type        = string
  description = "AWS region"
}

### VPC

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

### EC2

variable "ec2_asg_desired_capacity" {
  type        = number
  description = "EC2 Autoscaling Group desired capacity"
}

variable "ec2_asg_min_size" {
  type        = number
  description = "EC2 Autoscaling Group minimum size"
}

variable "ec2_asg_max_size" {
  type        = number
  description = "EC2 Autoscaling Group maximum size"
}

### RDS

variable "db_multi_az" {
  type        = bool
  description = "Whether to deploy to multi-az for RDS DB"
}
