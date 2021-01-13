provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "release_bucket_name" {
  type = string
}

resource "aws_s3_bucket" "release" {
  bucket = var.release_bucket_name
  acl    = "private"

  tags = {
    Name        = "release"
    Environment = "Prod"
  }
}

