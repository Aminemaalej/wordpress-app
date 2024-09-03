resource "aws_security_group" "lb" {
  name        = "wordpress-lb-sg"
  description = "wordpress ALB Security Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lb_egress" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow Outbound Traffic"
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
}

resource "aws_security_group_rule" "lb_ingress_443" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTPS External"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

resource "aws_security_group_rule" "lb_ingress_80" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTP External"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group" "ec2" {
  description = "Attached to the Wordpress EC2 instance to allow TCP traffic from ALB"
  name        = "wordpress-lb-ec2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound HTTP traffic from the load balancer to EC2"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
    to_port         = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound TCP traffic."
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
  }
}

resource "aws_lb" "wordpress_lb" {
  name               = "wordpress-alb-${data.aws_region.current.name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_a_id, var.private_subnet_b_id]
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "wordpress_lb" {
  name     = "wordpress-alb-${data.aws_region.current.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "wordpress_lb_listener_80" {
  load_balancer_arn = aws_lb.wordpress_lb.id
  port              = "80"
  protocol          = "HTTP"

  #   default_action {
  #     type = "redirect"

  #     redirect {
  #       port        = "443"
  #       protocol    = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_lb.arn
  }
}

# resource "aws_lb_listener" "wordpress_lb_listener_443" {
#   load_balancer_arn = aws_lb.wordpress_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
# #   certificate_arn   = "arn:aws:acm:eu-west-1:123456789012:certificate/abcdefg-1234-5678-90ab-cdefghijklmn" # Replace with your ACM certificate ARN

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.wordpress_lb.arn
#   }
# }
