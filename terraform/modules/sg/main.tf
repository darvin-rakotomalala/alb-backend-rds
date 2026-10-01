############################################
# SECURITY GROUPS
############################################

# ---------- ALB-SG: Public-facing Internet Edge ----------
resource "aws_security_group" "alb" {
  name        = "${var.naming_prefix}-alb-sg"
  description = "Security group for public-facing Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_from_internet" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from internet (redirected to HTTPS by the listener)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_internet" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Restrict ALB outbound traffic solely to the application tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

# ---------- EC2-APP-SG: Application Tier ----------
resource "aws_security_group" "app" {
  name        = "${var.naming_prefix}-ec2-app-sg"
  description = "Security group for Spring Boot application instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}-ec2-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow application traffic from ALB only"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow application tier to reach RDS PostgreSQL instance"
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_ssm_endpoints" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow HTTPS egress to SSM / Secrets Manager interface endpoints"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_https_egress" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS egress for OS updates, CloudWatch APIs and S3 (via gateway endpoint)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_http_egress" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP egress for Linux package repository mirrors"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ---------- RDS-SG: Database Tier ----------
resource "aws_security_group" "rds" {
  name        = "${var.naming_prefix}-rds-sg"
  description = "Security group for isolated RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Allow database traffic from application tier only"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

# Note: RDS requires zero egress rules — stateful connection tracking handles
# return responses to the app tier automatically.

# ---------- VPCE-SG: Interface VPC Endpoints (SSM + Secrets Manager) ----------
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.naming_prefix}-ssm-sg"
  description = "Security group for SSM and Secrets Manager Interface VPC Endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}-ssm-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_from_app" {
  security_group_id            = aws_security_group.vpc_endpoints.id
  description                  = "Allow HTTPS from application tier EC2 instances"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
