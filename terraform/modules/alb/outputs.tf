############################################
# ALB - OUTPUTS
############################################

output "alb_dns_name" {
  description = "The domain name (DNS name) of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer (used for Route 53 alias records)"
  value       = aws_lb.app.zone_id
}

output "alb_target_group_arn" {
  description = "The Amazon Resource Name (ARN) of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.app.arn_suffix
}

output "target_group_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb_target_group.app.arn_suffix
}

output "lb_listener_https" {
  description = "HTTPS of ALB listener"
  value       = aws_lb_listener.https.arn
}

output "lb_target_group_app_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app.arn
}
