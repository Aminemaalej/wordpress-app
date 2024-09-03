resource "aws_launch_template" "wordpress_lt" {
  name          = "wordpress-launch-template"
  image_id      = "ami-0034529272b0a8509"
  instance_type = "t3.micro"

  network_interfaces {
    security_groups             = [var.db_security_group, aws_security_group.ec2.id]
    associate_public_ip_address = false
    delete_on_termination       = true
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  vpc_zone_identifier = [var.private_subnet_a_id, var.private_subnet_b_id]
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  target_group_arns   = [aws_lb_target_group.wordpress_lb.arn]
  health_check_type   = "EC2"
#   health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
}
