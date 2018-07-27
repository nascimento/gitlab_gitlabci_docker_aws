provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "gitlab" {
  bucket = "gitlabcache"
  acl    = "private"

  tags {
    Name = "gitlab"
  }
}

# Create an IAM role for the Web Servers.
resource "aws_iam_role" "gitlab_runner_iam_role" {
  name               = "InstanceRoleGitlabRunner"
  assume_role_policy = "${file("${path.module}/data/role_trust.json")}"
}

resource "aws_iam_instance_profile" "gitlab_runner_instance_profile" {
  name = "InstanceProfileGitlabRunner"
  role = "${aws_iam_role.gitlab_runner_iam_role.name}"
}

resource "aws_iam_policy_attachment" "ec2_full" {
  name       = "ec2_full"
  roles      = ["${aws_iam_role.gitlab_runner_iam_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy_attachment" "s3_full" {
  name       = "s3_full"
  roles      = ["${aws_iam_role.gitlab_runner_iam_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "ec2_role" {
  name       = "ec2_role"
  roles      = ["${aws_iam_role.gitlab_runner_iam_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/data/user_data.sh")}"

  vars {
    vpc_id     = "${var.vpc_gitlab_id}"
    subnet_id  = "${var.subnet_gitlab_id}"
    gitlab_url = "${var.gitlab_url}"
    region     = "${var.region}"
    zone       = "c"
  }
}

# Primeira maquina de Runner, pode ser Spot, mas o ideal seria ser Ec2
resource "aws_spot_fleet_request" "gitlab_runner_spot" {
  iam_fleet_role      = "arn:aws:iam::881584977316:role/aws-ec2-spot-fleet-tagging-role"
  spot_price          = "0.02"
  allocation_strategy = "lowestPrice"
  target_capacity     = 1
  valid_until         = "2030-12-31T23:59:59Z"

  launch_specification {
    instance_type               = "${var.spot_instance_type}"
    ami                         = "${var.spot_ami}"
    spot_price                  = "${var.spot_max_price}"
    availability_zone           = "${var.region}c"
    subnet_id                   = "${var.subnet_gitlab_id}"
    vpc_security_group_ids      = ["${var.security_group_gitlab_id}"]
    key_name                    = "${var.spot_key_pair_name}"
    user_data                   = "${data.template_file.user_data.rendered}"
    iam_instance_profile        = "${aws_iam_instance_profile.gitlab_runner_instance_profile.name}"
    associate_public_ip_address = true

    root_block_device {
      volume_size           = "20"
      volume_type           = "gp2"
      delete_on_termination = true
    }

    tags {
      Name = "gitlab-runner-spot"
    }
  }
}
