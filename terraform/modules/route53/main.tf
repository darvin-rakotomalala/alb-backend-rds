############################################
# ROUTE 53
# Uses the existing hosted zone (var.route53_zone_id) for var.domain_name.
# Two alias A records point the domain at the ALB:
#   cloudwithdarvin.com      -> ALB (root/apex domain)
#   api.cloudwithdarvin.com  -> ALB
############################################

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false # Set to true if querying a private hosted zone
}

resource "aws_route53_record" "apex_alias" {
  zone_id = var.route53_zone_id # data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_alias" {
  zone_id = var.route53_zone_id # data.aws_route53_zone.main.zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
