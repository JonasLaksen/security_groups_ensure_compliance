module "evaluate_security_group_lambda" {
  source = "./lambdas/evaluate_sg"
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = module.evaluate_security_group_lambda.this.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

resource "aws_config_config_rule" "this" {
  name = "sg-rule"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = module.evaluate_security_group_lambda.this.arn

    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }

  depends_on = [
    aws_lambda_permission.this,
  ]
}

resource "aws_config_remediation_configuration" "this" {
  config_rule_name           = aws_config_config_rule.this.name
  target_id                  = "AWS-PublishSNSNotification"
  target_type                = "SSM_DOCUMENT"
  automatic                  = true
  maximum_automatic_attempts = 10
  retry_attempt_seconds      = 600

  parameter {
    name         = "TopicArn"
    static_value = aws_sns_topic.this.arn
  }
  parameter {
    name           = "Message"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.this.arn
  }
}

resource "aws_sns_topic" "this" {
  name = "security-group-remediation-topic"
}

resource "aws_iam_role" "this" {
  name = "ssm-allow-sns-remediation-topic-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name = "remediation-topic-policy"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["sns:*"],
        Effect   = "Allow",
        Resource = aws_sns_topic.this.arn
      }
    ]
  })
}

module "remediate_security_group_lambda" {
  source     = "./lambdas/remediate_sg"
  region     = var.region
  account_id = var.account_id
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = module.remediate_security_group_lambda.this.arn
}