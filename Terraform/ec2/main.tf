data "aws_region" "current" {}

# Cloudfront can be created only in us-east-1
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}
