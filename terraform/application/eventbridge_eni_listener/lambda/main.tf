module "lambda" {
  source      = "../../../modules/lambda"
  name        = "trigger_evaluation_of_added_sg_to_eni"
  root        = path.module
  role_policy = local.role_policy
  runtime     = "python3.9"
  environment_variables = {
    REGION     = var.region
    ACCOUNT_ID = var.account_id
  }
}