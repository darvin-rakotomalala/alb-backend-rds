############################################
# CloudWatch Monitoring for the EC2 Application Tier
############################################

resource "aws_cloudwatch_log_group" "app_tier" {
  name              = "/aws/ec2/spring-boot-backend-app-tier"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_cloudwatch_key_arn

  tags = {
    Name = "${var.naming_prefix}-app-tier-logs"
  }
}

############################################
# Metric Filters: extract ERROR / WARN counts from application logs
############################################

resource "aws_cloudwatch_log_metric_filter" "app_error" {
  name           = "${var.naming_prefix}-app-error-count"
  log_group_name = aws_cloudwatch_log_group.app_tier.name
  pattern        = "?ERROR ?Error ?error"

  metric_transformation {
    name          = "ApplicationErrorCount"
    namespace     = "${var.naming_prefix}/AppTier"
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "app_warning" {
  name           = "${var.naming_prefix}-app-warning-count"
  log_group_name = aws_cloudwatch_log_group.app_tier.name
  pattern        = "?WARN ?Warning ?warning"

  metric_transformation {
    name          = "ApplicationWarningCount"
    namespace     = "${var.naming_prefix}/AppTier"
    value         = "1"
    default_value = 0
  }
}

############################################
# CloudWatch Alarms — EC2 App Tier (one set per static instance)
############################################

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  for_each = { for idx, inst in var.aws_instance_app : coalesce(lookup(inst.tags, "Name", null), tostring(idx)) => inst }

  alarm_name          = "${var.naming_prefix}-app-${each.key}-cpu-high"
  alarm_description   = "Alert when CPU on ${each.value.tags.Name} exceeds 80% for 5 consecutive minutes"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  period              = 60
  evaluation_periods  = 5
  treat_missing_data  = "missing"

  dimensions = { InstanceId = each.value.id }

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-${each.key}-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  for_each = { for idx, inst in var.aws_instance_app : coalesce(lookup(inst.tags, "Name", null), tostring(idx)) => inst }

  alarm_name          = "${var.naming_prefix}-app-${each.key}-status-check-failed"
  alarm_description   = "Alert when ${each.value.tags.Name} fails EC2 status checks"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 60
  evaluation_periods  = 2
  treat_missing_data  = "missing"

  dimensions = { InstanceId = each.value.id }

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-${each.key}-status-check-failed"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory_high" {
  for_each = { for idx, inst in var.aws_instance_app : coalesce(lookup(inst.tags, "Name", null), tostring(idx)) => inst }

  alarm_name          = "${var.naming_prefix}-app-${each.key}-memory-high"
  alarm_description   = "Alert when memory usage on ${each.value.tags.Name} exceeds 90%"
  namespace           = "${var.naming_prefix}/EC2"
  metric_name         = "mem_used_percent"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 90
  period              = 60
  evaluation_periods  = 5
  treat_missing_data  = "missing"

  dimensions = { InstanceId = each.value.id }

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-${each.key}-memory-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_high" {
  for_each = { for idx, inst in var.aws_instance_app : coalesce(lookup(inst.tags, "Name", null), tostring(idx)) => inst }

  alarm_name          = "${var.naming_prefix}-app-${each.key}-disk-high"
  alarm_description   = "Alert when root-volume disk usage on ${each.value.tags.Name} exceeds 85%"
  namespace           = "${var.naming_prefix}/EC2"
  metric_name         = "disk_used_percent"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 85
  period              = 60
  evaluation_periods  = 5
  treat_missing_data  = "missing"

  dimensions = { InstanceId = each.value.id, path = "/" }

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-${each.key}-disk-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_error_count_high" {
  alarm_name          = "${var.naming_prefix}-app-error-count-high"
  alarm_description   = "This metric monitors application error logs across the whole app tier log group"
  namespace           = aws_cloudwatch_log_metric_filter.app_error.metric_transformation[0].namespace
  metric_name         = aws_cloudwatch_log_metric_filter.app_error.metric_transformation[0].name
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10
  period              = 300
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-error-count-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_warning_count_high" {
  alarm_name          = "${var.naming_prefix}-app-warning-count-high"
  alarm_description   = "This metric monitors application warning logs across the whole app tier log group"
  namespace           = aws_cloudwatch_log_metric_filter.app_warning.metric_transformation[0].namespace
  metric_name         = aws_cloudwatch_log_metric_filter.app_warning.metric_transformation[0].name
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 25
  period              = 300
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-warning-count-high"
  }
}

# ALB-level: alert when fewer healthy targets are registered than instances
# we expect to exist — the closest static-fleet equivalent of "low capacity"
# now that there's no ASG to report GroupInServiceInstances.
resource "aws_cloudwatch_metric_alarm" "app_healthy_targets_low" {
  alarm_name          = "${var.naming_prefix}-app-healthy-targets-low"
  alarm_description   = "Alert when fewer than ${var.app_instance_count} app instances are healthy behind the ALB"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  comparison_operator = "LessThanThreshold"
  threshold           = var.app_instance_count
  period              = 60
  evaluation_periods  = 3
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-healthy-targets-low"
  }
}

# Composite Alarm: overall application health status
resource "aws_cloudwatch_composite_alarm" "app_tier_health" {
  alarm_name        = "${var.naming_prefix}-app-tier-overall-health"
  alarm_description = "Composite: fires if any instance's CPU/memory/status-check breaches, error logs spike, or healthy target count drops"

  alarm_rule = join(" OR ", concat(
    [for a in aws_cloudwatch_metric_alarm.ec2_cpu_high : "ALARM(\"${a.alarm_name}\")"],
    [for a in aws_cloudwatch_metric_alarm.ec2_status_check_failed : "ALARM(\"${a.alarm_name}\")"],
    [
      "ALARM(\"${aws_cloudwatch_metric_alarm.app_healthy_targets_low.alarm_name}\")",
      "ALARM(\"${aws_cloudwatch_metric_alarm.app_error_count_high.alarm_name}\")",
    ]
  ))

  alarm_actions = [var.sns_alerts_topic_arn]
  ok_actions    = [var.sns_alerts_topic_arn]

  tags = {
    Name = "${var.naming_prefix}-app-tier-overall-health"
  }
}

############################################
# CloudWatch Dashboard — EC2 App Tier (all instances overlaid per widget)
############################################

locals {
  # One metrics-array entry per instance for widgets that overlay every
  # instance on the same graph (CPU, memory, disk, network).
  ec2_cpu_metrics = [
    for inst in var.aws_instance_app :
    ["AWS/EC2", "CPUUtilization", "InstanceId", inst.id, { stat = "Average", period = 60, label = inst.tags.Name }]
  ]

  ec2_mem_metrics = [
    for inst in var.aws_instance_app :
    ["${var.naming_prefix}/EC2", "mem_used_percent", "InstanceId", inst.id, { stat = "Average", period = 60, label = inst.tags.Name }]
  ]

  ec2_disk_metrics = [
    for inst in var.aws_instance_app :
    ["${var.naming_prefix}/EC2", "disk_used_percent", "InstanceId", inst.id, "path", "/", { stat = "Average", period = 60, label = inst.tags.Name }]
  ]

  ec2_network_in_metrics = [
    for inst in var.aws_instance_app :
    ["AWS/EC2", "NetworkIn", "InstanceId", inst.id, { stat = "Sum", period = 60, label = inst.tags.Name }]
  ]

  ec2_status_check_metrics = [
    for inst in var.aws_instance_app :
    ["AWS/EC2", "StatusCheckFailed", "InstanceId", inst.id, { stat = "Maximum", period = 60, label = inst.tags.Name }]
  ]
}

resource "aws_cloudwatch_dashboard" "app_tier" {
  dashboard_name = "${var.naming_prefix}-app-tier-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 8, height = 6,
        properties = {
          title   = "CPU Utilization (per instance)"
          region  = var.primary_region
          metrics = local.ec2_cpu_metrics
        }
      },
      {
        type = "metric", x = 8, y = 0, width = 8, height = 6,
        properties = {
          title   = "Memory Usage % (per instance)"
          region  = var.primary_region
          metrics = local.ec2_mem_metrics
        }
      },
      {
        type = "metric", x = 16, y = 0, width = 8, height = 6,
        properties = {
          title   = "Disk Usage % (per instance)"
          region  = var.primary_region
          metrics = local.ec2_disk_metrics
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 8, height = 6,
        properties = {
          title   = "Network In (per instance)"
          region  = var.primary_region
          metrics = local.ec2_network_in_metrics
        }
      },
      {
        type = "metric", x = 8, y = 6, width = 8, height = 6,
        properties = {
          title   = "Status Check Failures (per instance)"
          region  = var.primary_region
          metrics = local.ec2_status_check_metrics
        }
      },
      {
        type = "metric", x = 16, y = 6, width = 8, height = 6,
        properties = {
          title  = "Application Log Metrics (ERROR / WARN)"
          region = var.primary_region
          metrics = [
            ["${var.naming_prefix}/AppTier", "ApplicationErrorCount", { stat = "Sum", period = 300, label = "ERROR" }],
            ["${var.naming_prefix}/AppTier", "ApplicationWarningCount", { stat = "Sum", period = 300, label = "WARN" }],
          ]
        }
      },
      {
        type = "log", x = 0, y = 12, width = 16, height = 6,
        properties = {
          title  = "Recent Error Logs"
          region = var.primary_region
          view   = "table"
          query  = "SOURCE '${aws_cloudwatch_log_group.app_tier.name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
        }
      },
      {
        type = "metric", x = 16, y = 12, width = 8, height = 6,
        properties = {
          title  = "Healthy vs Unhealthy Targets (ALB view)"
          region = var.primary_region
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "Minimum", period = 60, label = "Healthy" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "Maximum", period = 60, label = "Unhealthy" }],
          ]
        }
      },
      {
        type = "metric", x = 0, y = 18, width = 12, height = 6,
        properties = {
          title  = "Request Rate & Target Response Time (p50/p99)"
          region = var.primary_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", period = 60, label = "Requests" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p50", period = 60, label = "p50" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p99", period = 60, label = "p99" }],
          ]
        }
      },
      {
        type = "metric", x = 12, y = 18, width = 12, height = 6,
        properties = {
          title   = "Estimated Daily Spend — EC2 (Billing metrics must be enabled in Account Settings)"
          region  = "us-east-1"
          metrics = [["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonEC2", "Currency", "USD", { stat = "Maximum", period = 86400 }]]
        }
      }
    ]
  })
}
