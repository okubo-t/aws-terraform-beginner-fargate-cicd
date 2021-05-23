locals {

  ecs-01 = {
    ## cluster
    cluster = {
      name = "${var.prefix}-${var.env}-cluster"
    }

    ## ecr
    ecr-01 = {
      name         = "${var.prefix}-${var.env}-${var.repo_name}"
      scan_on_push = "false"
    }

    ##  dafault task definition
    task-01 = {
      name = "${var.prefix}-${var.env}-taskdef"

      container_name = "${var.prefix}-${var.env}-${var.repo_name}"

      cwlog_name   = "/ecs/${var.prefix}-${var.env}"
      cwlog_prefix = var.repo_name

      task_role_arn      = aws_iam_role.task-01-role.arn
      execution_role_arn = aws_iam_role.taskexec-role-01.arn

    }

    ## service
    svc-01 = {

      desired_count = 0

      name = "${var.prefix}-${var.env}-service"

      subnet = [
        aws_subnet.public-subnet-01.id,
        aws_subnet.public-subnet-02.id,
      ]
      sg = [
        aws_security_group.ecs-01-sg.id,
      ]
      assign_public_ip = "true"

    }
  }

}

## cluster
resource "aws_ecs_cluster" "ecs-01_cluster-01" {
  name = local.ecs-01.cluster["name"]
}

## ecr
resource "aws_ecr_repository" "ecs-01_ecr-01" {
  name = local.ecs-01.ecr-01["name"]

  image_scanning_configuration {
    scan_on_push = local.ecs-01.ecr-01["scan_on_push"]

  }
}

## cloudwatch logs group
resource "aws_cloudwatch_log_group" "cwlogs-01" {
  name = local.ecs-01.task-01["cwlog_name"]

}

## task definitions
data "template_file" "taskdef-default" {

  template = file("./taskdef-default.json")

  vars = {
    awslogs-region = "${var.aws_region}"
    image          = aws_ecr_repository.ecs-01_ecr-01.repository_url
    name           = local.ecs-01.task-01["container_name"]
    awslogs-group  = local.ecs-01.task-01["cwlog_name"]
    awslogs-prefix = local.ecs-01.task-01["cwlog_prefix"]
  }
}

resource "aws_ecs_task_definition" "ecs-01_task-01" {
  family                = local.ecs-01.task-01["name"]
  container_definitions = data.template_file.taskdef-default.rendered

  cpu    = "256"
  memory = "512"

  task_role_arn            = local.ecs-01.task-01["task_role_arn"]
  execution_role_arn       = local.ecs-01.task-01["execution_role_arn"]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  lifecycle {
    ignore_changes = all
  }

}

## service
resource "aws_ecs_service" "ecs-01_svc-01" {

  depends_on = [aws_lb_target_group.alb-01_tg-01]

  name            = local.ecs-01.svc-01["name"]
  cluster         = aws_ecs_cluster.ecs-01_cluster-01.id
  task_definition = aws_ecs_task_definition.ecs-01_task-01.arn

  desired_count = local.ecs-01.svc-01["desired_count"]

  launch_type = "FARGATE"

  network_configuration {
    subnets          = local.ecs-01.svc-01["subnet"]
    security_groups  = local.ecs-01.svc-01["sg"]
    assign_public_ip = local.ecs-01.svc-01["assign_public_ip"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-01_tg-01.arn
    container_name   = local.ecs-01.task-01["container_name"]
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = all
  }

}
