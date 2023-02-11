resource "aws_cloudwatch_event_rule" "this" {
  name = "evaluate-newly-attached-security-groups-to-eni"

  event_pattern = jsonencode(
    {
      source      = ["aws.config"],
      detail-type = ["Config Configuration Item Change"],
      detail = {
        configurationItem = {
          resourceType = ["AWS::EC2::NetworkInterface"]
        }
      }
  })
}

module "lambda" {
  source     = "./lambda"
  region     = var.region
  account_id = var.account_id
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = module.lambda.this.arn
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.this.arn
  source_arn    = aws_cloudwatch_event_rule.this.arn
  principal     = "events.amazonaws.com"
  statement_id  = "AllowExecutionFromEventBridge"
}