
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


module "network" {
  source        = "./modules/network"
  naming_prefix = local.naming_prefix
}


module "instances" {
  source        = "./modules/instances"
  naming_prefix = local.naming_prefix
  public_subnet_id      = module.network.public_subnet_id
  private_subnet_id    = module.network.private_subnet_id
  ec2_security_group_id = module.network.ec2_security_group_id
}


