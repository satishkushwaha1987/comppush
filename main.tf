module "aws_vpc" {
  source = "git::https://bitbucket.org/compunnel-terraform-modules/terraform-aws-vpc.git?ref=v3.14.4"

  name = local.NamePrefix
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24", "10.0.153.0/24"]
  
  create_database_subnet_group = false
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options = true
  tags = var.common_tags
}
