locals {
  NamePrefix = "${var.company_name}-${var.environment}-vpc"
}

variable "common_tags" {
  type = map(string)
  default = {
    TechOwner      = "Saurabh Singh",
    TechOwnerEmail = "saurabh.singh@compunneldigital.com"
  }
}

variable "environment" {
  default = "dev"
}

variable "company_name" {
  default = "Compunnel"
}

variable "region" {
  default = "us-east-1"
}