resource "aws_security_group" "lb" {
  name        = "wordpress-lb-sg"
  description = "wordpress ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2" {
  description = "Attached to the Wordpress EC2 instance to allow TCP traffic from ALB"
  name        = "wordpress-lb-ec2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "wordpress_lb" {
  name               = "wordpress-alb-${data.aws_region.current.name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_a_id, var.public_subnet_b_id]
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "wordpress_lb" {
  name     = "wordpress-alb-${data.aws_region.current.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "wordpress_lb_listener_80" {
  load_balancer_arn = aws_lb.wordpress_lb.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_lb.arn
  }

  #   default_action {
  #     type = "redirect"

  #     redirect {
  #       port        = "443"
  #       protocol    = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }
}

# resource "aws_lb_listener" "wordpress_lb_listener_443" {
#   load_balancer_arn = aws_lb.wordpress_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
# #   certificate_arn   = "" # Replace with ACM certificate ARN

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.wordpress_lb.arn
#   }
# }
