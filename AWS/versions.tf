
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.17.0"
    }
  }
}

# AWS provider

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}
