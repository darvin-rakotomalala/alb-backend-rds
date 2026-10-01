# Data sources
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false # Set to true if querying a private hosted zone
}

# Availability zones available in the target region
data "aws_availability_zones" "available" {
  state = "available"
}
