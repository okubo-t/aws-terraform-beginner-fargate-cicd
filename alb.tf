locals {

  alb-01 = {
    name     = "${var.prefix}-${var.env}-alb"
    lb_type  = "application"
    internal = false

    vpc = aws_vpc.vpc-01.id
    subnet = [
      aws_subnet.public-subnet-01.id,
      aws_subnet.public-subnet-02.id,
    ]

    sg = [
      aws_security_group.alb-01-sg.id,
    ]

    ##access_log = aws_s3_bucket.access-log_.bucket

    listener-http = {
      default_action_type = "redirect"
    }

    listener-https = {
      ssl_policy      = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      certificate_arn = aws_acm_certificate.acm-01.arn
    }

    tg-01 = {
      name              = "${var.prefix}-${var.env}-tg"
      target_type       = "ip"
      port              = "80"
      protocol          = "HTTP"
      health_check_path = "/"
    }

  }

}

# lb
resource "aws_lb" "alb-01" {
  name               = local.alb-01["name"]
  load_balancer_type = local.alb-01["lb_type"]
  internal           = local.alb-01["internal"]
  security_groups    = local.alb-01["sg"]
  subnets            = local.alb-01["subnet"]

  /*
  access_logs {
    bucket  = local.alb-01["access_log"]
    enabled = true
  }
 */

  tags = {
    Name = local.alb-01["name"]

  }
}

# http listener
resource "aws_lb_listener" "alb-01_listener-http" {
  load_balancer_arn = aws_lb.alb-01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = local.alb-01.listener-http["default_action_type"]

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# https listener
resource "aws_lb_listener" "alb-01_listener-https" {
  load_balancer_arn = aws_lb.alb-01.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = local.alb-01.listener-https["ssl_policy"]
  certificate_arn = local.alb-01.listener-https["certificate_arn"]

  default_action {
    target_group_arn = aws_lb_target_group.alb-01_tg-01.arn
    type             = "forward"
  }

}

# target group
resource "aws_lb_target_group" "alb-01_tg-01" {
  name        = local.alb-01.tg-01["name"]
  target_type = local.alb-01.tg-01["target_type"]
  port        = local.alb-01.tg-01["port"]
  protocol    = local.alb-01.tg-01["protocol"]
  vpc_id      = local.alb-01["vpc"]

  deregistration_delay = 30

  health_check {
    interval            = 30
    path                = local.alb-01.tg-01["health_check_path"]
    protocol            = local.alb-01.tg-01["protocol"]
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }

  depends_on = [
    aws_lb.alb-01
  ]

}

