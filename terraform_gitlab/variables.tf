variable "region" {}

variable "cluster_name" {
  default = "GitlabPoc"
}

variable "spot_ami" {
  default = "ami-8f4e74ea" # ECS Image
}

variable "spot_instance_type" {
  default = "t2.small"
}

variable "spot_max_price" {
  default = "0.01" # Max 50% do valor de uma t2.small
}

variable "spot_key_pair_name" {
  default = "gitlab"
}

variable "security_group_gitlab_id" {}
variable "vpc_gitlab_id" {}
variable "subnet_gitlab_id" {}
variable "subnet_b_gitlab_id" {}
