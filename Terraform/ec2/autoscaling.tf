resource "aws_launch_template" "wordpress_lt" {
  name          = "wordpress-launch-template"
  image_id      = "ami-0034529272b0a8509"
  instance_type = "t3.micro"

  network_interfaces {
    security_groups             = [var.db_security_group, aws_security_group.ec2.id]
    associate_public_ip_address = false
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  # To test connectivity between EC2 and the ALB

  #   user_data = base64encode(<<-EOF
  #               #!/bin/bash
  #               sudo yum update -y
  #               sudo yum install -y httpd
  #               sudo systemctl start httpd
  #               sudo systemctl enable httpd
  #               echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  #               EOF
  #   )

}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  vpc_zone_identifier = [var.private_subnet_a_id, var.private_subnet_b_id]
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  target_group_arns   = [aws_lb_target_group.wordpress_lb.arn]

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
}
