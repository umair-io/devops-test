provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

resource "aws_s3_bucket" "wipro-release" {
  bucket = "wipro-release-uk"
  acl    = "private"

  tags = {
    Name        = "wipro-release"
    Environment = "Prod"
  }
}

