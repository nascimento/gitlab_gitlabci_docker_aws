provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "gitlab" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "gitlab"
  }
}

resource "aws_route_table" "gitlab" {
  vpc_id = "${aws_vpc.gitlab.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gitlab.id}"
  }

  tags {
    Name = "gitlab"
  }
}

resource "aws_subnet" "gitlab" {
  vpc_id            = "${aws_vpc.gitlab.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "gitlab"
  }
}

resource "aws_subnet" "gitlab_b" {
  vpc_id            = "${aws_vpc.gitlab.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "gitlab"
  }
}

resource "aws_internet_gateway" "gitlab" {
  vpc_id = "${aws_vpc.gitlab.id}"

  tags = {
    Name = "gitlab"
  }
}

resource "aws_security_group" "gitlab" {
  name        = "public"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.gitlab.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["187.50.200.224/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitlab"
  }
}

resource "aws_key_pair" "gitlab" {
  key_name   = "gitlab"
  public_key = "${var.ssh-rsa}"
}
