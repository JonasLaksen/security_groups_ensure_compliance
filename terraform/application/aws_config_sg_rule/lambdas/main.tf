module "evaluate_security_group" {
  source = "./evaluate_security_group"
}

module "remediate_security_group" {
  source     = "./remediate_security_group"
  account_id = var.account_id
  region     = var.region
}
