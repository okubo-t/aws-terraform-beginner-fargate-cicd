output "url" {
  value = "https://${aws_route53_record.r53_rec-01.fqdn}"
}

output "codecommit_repository" {
  value = aws_codecommit_repository.repo-01.clone_url_http
}

output "ecr_repository" {
  value = aws_ecr_repository.ecs-01_ecr-01.repository_url
}
