variable "region" {}

variable "bucket_cache_name" {
  default = "gitlab_cache"
}

variable "spot_ami" {
  default = "ami-8c122be9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "spot_instance_type" {
  default = "t2.medium"
}

variable "spot_max_price" {
  default = "0.02" # Max 50% do valor de uma t2.small
}

variable "spot_key_pair_name" {
  default = "gitlab"
}

variable "security_group_gitlab_id" {}
variable "vpc_gitlab_id" {}
variable "subnet_gitlab_id" {}
variable "subnet_b_gitlab_id" {}
