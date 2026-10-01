############################################
# Network ACLs (stateless, defense-in-depth layer on top of Security Groups)
############################################

locals {
  public_subnet_cidr_map = { for idx, cidr in var.public_subnet_cidrs : cidr => idx }
  app_subnet_cidr_map    = { for idx, cidr in var.app_subnet_cidrs : cidr => idx }
  db_subnet_cidr_map     = { for idx, cidr in var.db_subnet_cidrs : cidr => idx }
}

# ================= PUBLIC SUBNETS NACL =================
resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.naming_prefix}-public-nacl"
  }
}

resource "aws_network_acl_rule" "public_in_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_in_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Path MTU Discovery: without this, large TCP packets can silently drop
# instead of triggering fragmentation, causing intermittent stalls.
resource "aws_network_acl_rule" "public_in_icmp_pmtu" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = 3
  icmp_code      = 4
}

resource "aws_network_acl_rule" "public_out_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_out_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_out_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_out_icmp_pmtu" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  egress         = true
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = 3
  icmp_code      = 4
}

# ================= APPLICATION-TIER SUBNETS NACL =================
resource "aws_network_acl" "app" {
  vpc_id     = var.vpc_id
  subnet_ids = var.app_subnet_ids

  tags = {
    Name = "${var.naming_prefix}-app-nacl"
  }
}

# Inbound: app traffic, scoped per public-tier subnet CIDR rather than the
# whole VPC, so only the public tier can reach the app port.
resource "aws_network_acl_rule" "app_in_from_public" {
  for_each       = local.public_subnet_cidr_map
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100 + each.value
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = var.app_port
  to_port        = var.app_port
}

# Inbound: ephemeral return traffic for the app tier's own outbound calls
# (internet for http/https, db tier for postgres). Left open to 0.0.0.0/0
# since one of those destinations (the internet) is itself unbounded.
resource "aws_network_acl_rule" "app_in_ephemeral" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "app_in_icmp_pmtu" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 210
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = 3
  icmp_code      = 4
}

resource "aws_network_acl_rule" "app_out_http" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "app_out_https" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Outbound: app -> db, scoped per db-tier subnet CIDR instead of the whole
# VPC, matching the precision already used on the db NACL's ingress side.
resource "aws_network_acl_rule" "app_out_to_db" {
  for_each       = local.db_subnet_cidr_map
  network_acl_id = aws_network_acl.app.id
  rule_number    = 200 + each.value
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = var.db_port
  to_port        = var.db_port
}

# Outbound: ephemeral response traffic back to the public tier (answering
# the inbound app-port requests above), scoped to public subnets instead
# of the whole VPC.
resource "aws_network_acl_rule" "app_out_ephemeral_to_public" {
  for_each       = local.public_subnet_cidr_map
  network_acl_id = aws_network_acl.app.id
  rule_number    = 300 + each.value
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "app_out_icmp_pmtu" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 400
  egress         = true
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = 3
  icmp_code      = 4
}

# ================= DATABASE-TIER SUBNETS NACL =================
resource "aws_network_acl" "db" {
  vpc_id     = var.vpc_id
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.naming_prefix}-db-nacl"
  }
}

# Inbound: PostgreSQL traffic, one rule per app-tier subnet CIDR. Uses a
# cidr => index map instead of toset()+index() so rule numbers are stable
# and collision-free even if var.app_subnet_cidrs ever has a duplicate.
resource "aws_network_acl_rule" "db_in_postgres_app" {
  for_each       = local.app_subnet_cidr_map
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100 + each.value
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = var.db_port
  to_port        = var.db_port
}

resource "aws_network_acl_rule" "db_in_icmp_pmtu" {
  for_each       = local.app_subnet_cidr_map
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200 + each.value
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = each.key
  icmp_type      = 3
  icmp_code      = 4
}

resource "aws_network_acl_rule" "db_out_ephemeral_app" {
  for_each       = local.app_subnet_cidr_map
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100 + each.value
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "db_out_icmp_pmtu" {
  for_each       = local.app_subnet_cidr_map
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200 + each.value
  egress         = true
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = each.key
  icmp_type      = 3
  icmp_code      = 4
}
