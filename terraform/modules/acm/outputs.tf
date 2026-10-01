############################################
# DNS / Certificate OUTPUTS
############################################

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate used by the ALB HTTPS listener"
  value       = aws_acm_certificate_validation.alb.certificate_arn
}
