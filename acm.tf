locals {

  acm-01 = {
    domain_name = "${var.repo_name}.${var.hosted_zone}"
  }

}

/*
data "aws_acm_certificate" "acm-01" {
  domain   = local.acm-01["domain_name"]
  statuses = ["ISSUED"]
}
*/

resource "aws_acm_certificate" "acm-01" {
  domain_name = local.acm-01["domain_name"]

  validation_method = "DNS"

  tags = {
    Name = local.acm-01["domain_name"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
