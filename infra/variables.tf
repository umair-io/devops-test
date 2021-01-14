variable "region" {
  type = string
  default = "us-east-1"
}

variable "release_bucket_name" {
  type = string
  description = "bucket name where code will be shipped to"
  default = "wipro-release-uk-1" #HAS to start with wipro-release to work!!
}

variable "my_key_pair" {
    type = string
    description = "keypair to access instances in asg"
    default = "deployer-key"
}

variable "vpc_cidr" {
    type = string
    description = "CIDR for the VPC"
    default = "10.0.0.0/16"
}

variable "subnet_a_cidr" {
    type = string
    description = "CIDR for the Subnet A"
    default = "10.0.0.0/24"
}

variable "subnet_b_cidr" {
    type = string
    description = "CIDR for the Subnet B"
    default = "10.0.1.0/24"
}

variable "wipro-app-local-port" {
  type = string
  description = "local port behind the LB"
  default = "3000"
}