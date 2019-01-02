/**
* ## Project: app-ecs-services
*
* Create services and task definitions for the ECS cluster
*
*/

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "stack_name" {
  type        = "string"
  description = "Unique name for this collection of resources"
  default     = "dev"
}

variable "use_staging_dead_mans_switch" {
  type        = "string"
  description = "Flag to use staging dead mans switch"
  default     = "false"
}

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket = "re-prom-dev-tfstate"
    key    = "app-ecs-services-modular.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version             = "~> 1.17"
  allowed_account_ids = ["931679966755"]
  region              = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0.0"
}

provider "pass" {
  store_dir     = "~/.password-store/re-secrets/observe"
  refresh_store = true
}

data "pass_password" "cronitor_staging_url" {
  path = "cronitor/cronitor-staging-url"
}

variable "remote_state_bucket" {
  type        = "string"
  description = "S3 bucket we store our terraform state in"
  default     = "re-prom-dev-tfstate"
}

module "app-ecs-services" {
  source = "../../modules/app-ecs-services"

  dev_environment            = "true"
  remote_state_bucket        = "${var.remote_state_bucket}"
  stack_name                 = "${var.stack_name}"
  dev_ticket_recipient_email = "test@example.com"
  dead_mans_switch_cronitor  = "${var.use_staging_dead_mans_switch == "true" ? "${data.pass_password.cronitor_staging_url.password}" : "http://localhost/"}"
}
