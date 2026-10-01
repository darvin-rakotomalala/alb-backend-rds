############################################
# VPC NETWORKING
############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.naming_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.naming_prefix}-igw"
  }
}

locals {
  az_count          = length(var.availability_zones)
  nat_gateway_count = var.single_nat_gateway ? 1 : local.az_count
}

# One Elastic IP per AZ for highly-available NAT Gateways (Technical Spec: 3 NAT GWs, one per AZ)
resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = {
    Name = "${var.naming_prefix}-nat-eip-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.naming_prefix}-nat-gw-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}

############################################
# Subnets — CIDRs per Technical Spec (18.0.0.0/16)
#   Public:  18.0.1.0/24  18.0.2.0/24  18.0.3.0/24
#   App:     18.0.11.0/24 18.0.12.0/24 18.0.13.0/24
#   Data:    18.0.21.0/24 18.0.22.0/24 18.0.23.0/24
############################################

# ---------- Public subnets (ALB tier, 3 AZs) ----------
resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1) # .1.0/24, .2.0/24, .3.0/24
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.naming_prefix}-public-${var.availability_zones[count.index]}"
    Tier = "public"
  }
}

# ---------- Private subnets (Application tier, egress via NAT, 3 AZs) ----------
resource "aws_subnet" "app" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 11) # .11.0/24, .12.0/24, .13.0/24
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.naming_prefix}-app-${var.availability_zones[count.index]}"
    Tier = "application"
  }
}

# ---------- Private subnets (Database tier, fully isolated, 3 AZs) ----------
resource "aws_subnet" "db" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 21) # .21.0/24, .22.0/24, .23.0/24
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.naming_prefix}-db-${var.availability_zones[count.index]}"
    Tier = "database"
  }
}

# ---------- RDS DB Subnet Group ----------
resource "aws_db_subnet_group" "main" {
  name        = "${var.naming_prefix}-db-subnet-group"
  description = "DB subnet group spanning the isolated database-tier subnets across ${local.az_count} AZs"
  subnet_ids  = aws_subnet.db[*].id

  tags = {
    Name = "${var.naming_prefix}-db-subnet-group"
  }
}

############################################
# Route Tables
############################################

# ---------- Public Route Table (-> Internet Gateway) ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.naming_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------- Application-tier Route Tables (-> NAT Gateway, one per AZ for HA) ----------
resource "aws_route_table" "app" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.naming_prefix}-app-rt-${var.availability_zones[count.index]}"
  }
}

resource "aws_route" "app_nat_access" {
  count                  = local.az_count
  route_table_id         = aws_route_table.app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "app" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# ---------- Database-tier Route Table (no internet access, no NAT) ----------
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.naming_prefix}-db-rt"
  }
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
