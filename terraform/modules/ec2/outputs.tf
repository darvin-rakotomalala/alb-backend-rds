############################################
# EC2 OUTPUTS
############################################

output "app_instance_ids" {
  description = "IDs of the static application-tier EC2 instances"
  value       = aws_instance.app[*].id
}

output "app_instance_private_ips" {
  value = aws_instance.app[*].private_ip
}

output "ec2_availability_zones" {
  description = "Availability zones the application EC2 instances are deployed in"
  value       = aws_instance.app[*].availability_zone
}

# ---------- Exposed for other modules (e.g. cloudwatch-ec2) ----------
output "aws_instance_app" {
  description = "App tier EC2 instances (id + tags only), for building CloudWatch alarms/dashboards in other modules."
  value = [
    for inst in aws_instance.app : {
      id   = inst.id
      tags = inst.tags
    }
  ]
}
