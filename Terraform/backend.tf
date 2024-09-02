terraform {
  backend "s3" {
    bucket         = "nasdaq-tfstate-wordpress-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "wordpress-tfstate-locking"
    encrypt        = true
  }
}