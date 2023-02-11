module "lambda" {
  source      = "../../../../modules/lambda"
  name        = "evaluate-security-group"
  root        = path.module
  role_policy = local.role_policy
  runtime     = "python3.9"
}