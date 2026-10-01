############################################
# VPC - OUTPUTS
############################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "List of IDs of the application (private) subnets"
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "List of IDs of the database (isolated) subnets"
  value       = aws_subnet.db[*].id
}

output "app_route_table_ids" {
  description = "IDs of the application tier route tables"
  value       = aws_route_table.app[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "app_subnet_cidrs" {
  description = "CIDR blocks for the application private subnets"
  value       = aws_subnet.app[*].cidr_block
}

output "db_subnet_cidrs" {
  description = "CIDR blocks for the database private subnets"
  value       = aws_subnet.db[*].cidr_block
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group"
  value       = aws_db_subnet_group.main.name
}
