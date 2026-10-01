############################################
# VPC FLOW LOGS (Security & Compliance)
############################################

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}-vpc-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/${var.naming_prefix}-flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_cloudwatch_key_arn
}

resource "aws_iam_role" "flow_log" {
  name = "${var.naming_prefix}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.naming_prefix}-vpc-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid = "WriteFlowLogsToLogGroup"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.flow_log.arn}:*"
    }]
  })
}
