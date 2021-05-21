locals {

  ## task role
  task-01-role = {
    name = "${var.prefix}-${var.env}-task-role"

    policy-01 = {
      name = "${var.prefix}-${var.env}-task-policy"
    }

  }

  ## task execution role
  taskexec-role-01 = {
    name = "${var.prefix}-${var.env}-task-exec-role"

    ## policy-01: AmazonECSTaskExecutionRolePolicy

  }

  ## codebuild role
  cb-01-role = {
    name = "${var.prefix}-${var.env}-cb-role"

    policy-01 = {
      name = "${var.prefix}-${var.env}-cb-policy"
    }
    ## policy-02: AmazonEC2ContainerRegistryPowerUser

  }

  ## codepipeline role
  cp-01-role = {
    name = "${var.prefix}-${var.env}-cp-role"

    policy-01 = {
      name = "${var.prefix}-${var.env}-cp-policy"
    }
  }

  ## cloudwatch events role
  cwe-01-role = {
    name = "${var.prefix}-${var.env}-cwe-role"

    policy-01 = {
      name = "${var.prefix}-${var.env}-cwe-policy"
    }

  }

}

## task role
resource "aws_iam_role" "task-01-role" {
  name               = local.task-01-role["name"]
  assume_role_policy = file("./iam-policy/ecs-task-trust-policy.json")
}

resource "aws_iam_policy" "task-01-role_policy-01" {
  name   = local.task-01-role.policy-01["name"]
  policy = file("./iam-policy/ecs-task-policy.json")
}

resource "aws_iam_role_policy_attachment" "task-01-role_policy-01_attach" {
  policy_arn = aws_iam_policy.task-01-role_policy-01.arn
  role       = aws_iam_role.task-01-role.id
}

## task execution role
resource "aws_iam_role" "taskexec-role-01" {
  name               = local.taskexec-role-01["name"]
  assume_role_policy = file("./iam-policy/ecs-task-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "taskexec-role-01_policy-01_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.taskexec-role-01.id
}

## codebuild role
resource "aws_iam_role" "cb-01-role" {
  name               = local.cb-01-role["name"]
  assume_role_policy = file("./iam-policy/codebuild-trust-policy.json")
}

resource "aws_iam_policy" "cb-01-role_policy-01" {
  name   = local.cb-01-role.policy-01["name"]
  policy = file("./iam-policy/codebuild-policy.json")
}

resource "aws_iam_role_policy_attachment" "cb-01-role_policy-01_attach" {
  policy_arn = aws_iam_policy.cb-01-role_policy-01.arn
  role       = aws_iam_role.cb-01-role.id
}

resource "aws_iam_role_policy_attachment" "cb-01-role_policy-02_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.cb-01-role.id
}

## codepipeline role
resource "aws_iam_role" "cp-01-role" {
  name               = local.cp-01-role["name"]
  assume_role_policy = file("./iam-policy/codepipeline-trust-policy.json")
}

resource "aws_iam_policy" "cp-01-role_policy-01" {
  name   = local.cp-01-role.policy-01["name"]
  policy = file("./iam-policy/codepipeline-policy.json")
}

resource "aws_iam_role_policy_attachment" "cp-01-role_policy-01_attach" {
  policy_arn = aws_iam_policy.cp-01-role_policy-01.arn
  role       = aws_iam_role.cp-01-role.id
}

## cloudwatch events role
resource "aws_iam_role" "cwe-01-role" {
  name               = local.cwe-01-role["name"]
  assume_role_policy = file("./iam-policy/cloudwatch-event-trust-policy.json")
}

resource "aws_iam_policy" "cwe-01-role_policy-01" {
  name   = local.cwe-01-role.policy-01["name"]
  policy = file("./iam-policy/cloudwatch-event-policy.json")
}

resource "aws_iam_role_policy_attachment" "cwe-01-role_policy-01_attach" {
  policy_arn = aws_iam_policy.cwe-01-role_policy-01.arn
  role       = aws_iam_role.cwe-01-role.id
}
