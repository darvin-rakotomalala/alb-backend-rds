############################################
# NCALs OUTPUTS
############################################

output "public_nacl_id" {
  description = "ID of the public subnets Network ACL"
  value       = aws_network_acl.public.id
}

output "app_nacl_id" {
  description = "ID of the application-tier subnets Network ACL"
  value       = aws_network_acl.app.id
}

output "db_nacl_id" {
  description = "ID of the database-tier subnets Network ACL"
  value       = aws_network_acl.db.id
}
