variable "region" {}

variable "ami" {
  default = "ami-8c122be9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  default = "t2.small"
}

variable "security_group_gitlab_id" {}
variable "vpc_gitlab_id" {}
variable "subnet_gitlab_id" {}
variable "subnet_b_gitlab_id" {}
variable "key_pair_name" {}
