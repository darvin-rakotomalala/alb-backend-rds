############################################
# ROUTE 53 VARIABLES
############################################

output "route53_record_fqdns" {
  description = "DNS names that resolve to the ALB"
  value = [
    aws_route53_record.apex_alias.fqdn,
    aws_route53_record.api_alias.fqdn,
  ]
}
