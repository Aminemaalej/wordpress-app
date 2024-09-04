resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-sg"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]
}

resource "aws_security_group" "wordpress_db_security_group" {
  name        = "wordpress-db-sg"
  description = "wordpress-db Security Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "wordpress_db_security_group_egress" {
  security_group_id = aws_security_group.wordpress_db_security_group.id
  description       = "wordpress-db allow all egress"

  type        = "egress"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = "0"
  to_port     = "0"
}

resource "aws_security_group_rule" "wordpress_db_security_group_postgres" {
  security_group_id = aws_security_group.wordpress_db_security_group.id
  description       = "wordpress-db allow MySQL port 3306"

  type      = "ingress"
  protocol  = "tcp"
  self      = "true"
  from_port = 3306
  to_port   = 3306
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage          = 20
  apply_immediately          = "true"
  auto_minor_version_upgrade = false
  db_subnet_group_name       = aws_db_subnet_group.wordpress_db_subnet_group.name
  deletion_protection        = false
  skip_final_snapshot        = true
  engine                     = "mysql"
  engine_version             = "8.0"
  identifier                 = "wordpress-db"
  instance_class             = "db.t3.micro"
  multi_az                   = var.db_multi_az
  password                   = "nasdaq-wordpress-db-password"
  parameter_group_name       = "default.mysql8.0"
  publicly_accessible        = false
  storage_encrypted          = false
  storage_type               = "gp2"
  username                   = "nasdaqwordpressdbadmin"
  vpc_security_group_ids     = [aws_security_group.wordpress_db_security_group.id]
}
