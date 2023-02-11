module "lambda" {
  source      = "../../../../modules/lambda"
  name        = "remediate-security-group"
  root        = path.module
  role_policy = local.role_policy
  runtime     = "python3.9"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromSns"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.this.arn
  principal     = "sns.amazonaws.com"
}