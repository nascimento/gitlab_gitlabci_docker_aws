provider "aws" {
  region = "${var.region}"
}

module "terraform_global" {
  source = "./terraform_global"
  region = "${var.region}"
}

module "terraform_gitlab" {
  source = "./terraform_gitlab"

  security_group_gitlab_id = "${module.terraform_global.security_group_gitlab_id}"
  vpc_gitlab_id            = "${module.terraform_global.vpc_gitlab_id}"
  subnet_gitlab_id         = "${module.terraform_global.subnet_gitlab_id}"
  subnet_b_gitlab_id       = "${module.terraform_global.subnet_b_gitlab_id}"
  region                   = "${var.region}"
  key_pair_name            = "${module.terraform_global.key_pair_name}"
}

module "terraform_gitlab-runner" {
  source = "./terraform_gitlab-runner"

  security_group_gitlab_id = "${module.terraform_global.security_group_gitlab_id}"
  vpc_gitlab_id            = "${module.terraform_global.vpc_gitlab_id}"
  subnet_gitlab_id         = "${module.terraform_global.subnet_gitlab_id}"
  subnet_b_gitlab_id       = "${module.terraform_global.subnet_b_gitlab_id}"
  gitlab_url               = "${module.terraform_gitlab.gitlab_url}"
  region                   = "${var.region}"
}

variable "region" {
  default = "us-east-2"
}
