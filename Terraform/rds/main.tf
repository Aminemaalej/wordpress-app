data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-sg"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]
}

resource "aws_security_group" "wordpress_db_security_group" {
  name        = "wordpress-db Security Group"
  description = "wordpress-db Security Group"
  vpc_id      = var.vpc_id
}


resource "aws_db_instance" "wordpress_db" {
  allocated_storage          = 20
  apply_immediately          = "true"
  auto_minor_version_upgrade = false
  db_subnet_group_name       = aws_db_subnet_group.wordpress_db_subnet_group.name
  deletion_protection        = true
  engine                     = "postgres"
  engine_version             = "16.4"
  identifier                 = "wordpress-db"
  instance_class             = "db.t3.micro"
  multi_az                   = var.db_multi_az
  password                   = "nasdaq-wordpress-db-password"
  publicly_accessible        = false
  storage_encrypted          = false
  storage_type               = "gp2"
  username                   = "nasdaqwordpressdbadmin"
  vpc_security_group_ids     = [aws_security_group.wordpress_db_security_group.id]
}
