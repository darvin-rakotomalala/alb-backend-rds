############################################
# Application Load Balancer (public-facing, 3 AZs)
############################################

resource "aws_lb" "app" {
  name               = "${var.naming_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = true
  drop_invalid_header_fields = true

  tags = {
    Name = "${var.naming_prefix}-alb"
  }
}

# ---------- Target Group: forwards to the static Spring Boot app-tier instances ----------
resource "aws_lb_target_group" "app" {
  name        = "${var.naming_prefix}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }

  # create_before_destroy avoids a brief gap in target-group availability
  # during a target-group replacement (e.g. health-check path change).
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.naming_prefix}-app-tg"
  }
}

# ---------- Listener 80 (HTTP) -> redirect to HTTPS ----------
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ---------- Listener 443 (HTTPS) ----------
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # supports TLS 1.2 and TLS 1.3
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
