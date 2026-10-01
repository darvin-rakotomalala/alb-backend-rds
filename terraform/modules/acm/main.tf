############################################
# ACM Certificate
# SSL/TLS certificate with DNS validation, used by the ALB HTTPS listener.
# Covers both the root domain and the api.<domain> subdomain, validated
# against the existing Route 53 hosted zone (var.route53_zone_id).
############################################

resource "aws_acm_certificate" "alb" {
  domain_name               = var.domain_name
  subject_alternative_names = ["${var.api_subdomain}.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.naming_prefix}-alb-cert"
  }
}

# DNS validation record(s) — one per domain covered by the certificate
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Blocks until ACM confirms the DNS validation records above have propagated
resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for r in aws_route53_record.acm_validation : r.fqdn]
}
