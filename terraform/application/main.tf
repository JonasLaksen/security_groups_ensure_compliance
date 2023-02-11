terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "aws_config_sg_rule" {
  source     = "./aws_config_sg_rule"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

module "eventbridge_eni_listener" {
  source     = "./eventbridge_eni_listener"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}