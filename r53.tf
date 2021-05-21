locals {

  rec-01 = {
    domain_name = "${var.repo_name}.${var.hosted_zone}"
  }

}

## route53 zone
data "aws_route53_zone" "r53_zone-01" {
  name = var.hosted_zone
}

## route53 record
resource "aws_route53_record" "r53_rec-01" {
  zone_id = data.aws_route53_zone.r53_zone-01.id
  name    = local.rec-01["domain_name"]
  type    = "A"

  alias {
    name                   = aws_lb.alb-01.dns_name
    zone_id                = aws_lb.alb-01.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "r53_rec-02" {
  zone_id = data.aws_route53_zone.r53_zone-01.id
  name    = aws_acm_certificate.acm-01.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.acm-01.domain_validation_options.0.resource_record_type

  records = [
    aws_acm_certificate.acm-01.domain_validation_options.0.resource_record_value
  ]

  ttl = 60
}
