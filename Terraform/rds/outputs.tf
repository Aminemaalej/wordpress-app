output "db_security_group" {
  value = aws_security_group.wordpress_db_security_group.id
}
