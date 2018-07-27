provider "aws" {
  region = "${var.region}"
}

# CLUSTER ECS
resource "aws_instance" "gitlab" {
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami}"
  availability_zone           = "${var.region}c"
  subnet_id                   = "${var.subnet_gitlab_id}"
  vpc_security_group_ids      = ["${var.security_group_gitlab_id}"]
  key_name                    = "${var.key_pair_name}"
  user_data                   = "${file("${path.module}/data/user_data.sh")}"
  associate_public_ip_address = true

  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags {
    Name = "gitlab"
  }
}
