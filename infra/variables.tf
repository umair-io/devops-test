variable "region" {
  type = string
  default = "us-east-1"
}

variable "release_bucket_name" {
  type = string
  description = "bucket name where code will be shipped to"
  default = "wipro-release-uk"
}

variable "my_key_pair" {
    type = string
    description = "keypair to access instances in asg"
    default = "deployer-key"
}
