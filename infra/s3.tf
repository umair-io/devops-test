resource "aws_s3_bucket" "release" {
  bucket = var.release_bucket_name
  acl    = "private"

  tags = {
    Name        = "release"
    Environment = "Prod"
  }
}