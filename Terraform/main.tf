terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"

  aws_region = var.aws_region
}

module "rds" {
  source = "./rds"

  db_multi_az         = var.db_multi_az
  vpc_id              = module.vpc.vpc_id
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
}

module "ec2" {
  source = "./ec2"

  vpc_id              = module.vpc.vpc_id
  public_subnet_a_id  = module.vpc.public_subnet_a_id
  public_subnet_b_id  = module.vpc.public_subnet_b_id
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id

  db_security_group = module.rds.db_security_group

  asg_desired_capacity = var.ec2_asg_desired_capacity
  asg_min_size         = var.ec2_asg_min_size
  asg_max_size         = var.ec2_asg_max_size
}
