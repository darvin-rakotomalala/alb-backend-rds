############################################
# Application Tier — Static EC2 Instances (no Auto Scaling Group)
############################################

# Latest Ubuntu 24.04 LTS (Noble Numbat) AMI, owned by Canonical
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  az_count = length(var.availability_zones)
}

resource "aws_instance" "app" {
  count = var.app_instance_count

  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.app_subnet_ids[count.index % local.az_count]
  vpc_security_group_ids = [var.app_security_group_id]
  iam_instance_profile   = var.ec2_app_instance_profile_name

  # No public IP — SSM-only access, matches the "no bastion, no SSH inbound,
  # no public IP" requirement.
  associate_public_ip_address = false

  ebs_optimized = true
  monitoring    = true # 1-minute detailed CloudWatch monitoring

  metadata_options {
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.naming_prefix}-app-server-${var.availability_zones[count.index % local.az_count]}"
    AZ   = var.availability_zones[count.index % local.az_count]
  }

  depends_on = [
    var.db_instance_main,
    var.lb_listener_https,
  ]
}

# ---------- Register each instance with the ALB target group ----------
resource "aws_lb_target_group_attachment" "app" {
  count = var.app_instance_count

  target_group_arn = var.lb_target_group_app_arn
  target_id        = aws_instance.app[count.index].id
  port             = var.app_port
}
