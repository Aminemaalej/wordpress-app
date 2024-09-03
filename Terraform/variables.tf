variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "db_multi_az" {
  type        = bool
  description = "Whether to deploy to multi-az for RDS DB"
}