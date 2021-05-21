locals {

  ecs-01-sg = {
    name        = "${var.prefix}-${var.env}-ecs-sg"
    description = "SG for ECS Service"
    vpc         = aws_vpc.vpc-01.id
  }

  alb-01-sg = {
    name        = "${var.prefix}-${var.env}-alb-sg"
    description = "SG for ALB"
    vpc         = aws_vpc.vpc-01.id
  }

}

# ecs
resource "aws_security_group" "ecs-01-sg" {
  name        = local.ecs-01-sg["name"]
  description = local.ecs-01-sg["description"]
  vpc_id      = local.ecs-01-sg["vpc"]

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb-01-sg.id,

    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = local.ecs-01-sg["name"]
  }

}

# alb
resource "aws_security_group" "alb-01-sg" {
  name        = local.alb-01-sg["name"]
  description = local.alb-01-sg["description"]
  vpc_id      = local.alb-01-sg["vpc"]

  ingress {
    description = "source ip"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = [
      var.source_ip,

    ]
  }

  ingress {
    description = "source ip"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = [
      var.source_ip,

    ]

  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = local.alb-01-sg["name"]
  }

}
