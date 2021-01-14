provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }

  required_version = "~> 0.14"
}