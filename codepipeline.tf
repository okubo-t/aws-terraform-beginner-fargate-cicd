locals {

  cp-01 = {
    name        = "${var.prefix}-${var.env}-${var.repo_name}-cp"
    description = "${var.env} CodePipeline"

    artifact_store_name = "${var.prefix}-${var.env}-${var.repo_name}-artifact"

  }

}

## s3 bucket
resource "aws_s3_bucket" "artifact_store" {
  bucket        = local.cp-01["artifact_store_name"]
  region        = var.aws_region
  acl           = "private"
  force_destroy = true
}

## codepipeline
resource "aws_codepipeline" "cp-01" {
  name     = local.cp-01["name"]
  role_arn = aws_iam_role.cp-01-role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      run_order        = 1
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.repo-01.repository_name
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      namespace        = "BuildVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cb-01.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      namespace       = "DeployVariables"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.ecs-01_cluster-01.name
        ServiceName = aws_ecs_service.ecs-01_svc-01.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
