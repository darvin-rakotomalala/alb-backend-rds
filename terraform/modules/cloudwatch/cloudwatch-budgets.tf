############################################
# AWS Budgets: month-to-date spend vs budget + end-of-month forecast
# Supports the "Daily spend / Month-to-date vs budget / Forecast" call-outs
# in the Technical Spec for the EC2 and RDS dashboards.
############################################

resource "aws_budgets_budget" "ec2" {
  name         = "${var.naming_prefix}-ec2-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_ec2_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.sns_alerts_topic_arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.sns_alerts_topic_arn]
  }
}

resource "aws_budgets_budget" "rds" {
  name         = "${var.naming_prefix}-rds-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_rds_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Relational Database Service"]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.sns_alerts_topic_arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.sns_alerts_topic_arn]
  }
}
