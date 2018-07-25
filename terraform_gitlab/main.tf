provider "aws" {
  region = "${var.region}"
}

# CLUSTER ECS

resource "aws_ecs_cluster" "gitlab" {
  name = "${var.cluster_name}"
}

# IAM Role for ECS Instances in EC2
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRoleGitlab"
  assume_role_policy = "${file("${path.module}/data/role_trust.json")}"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRoleGitlab"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_policy_attachment" "ecs_service_role" {
  name       = "ecs_service_role"
  roles      = ["${aws_iam_role.ecs_instance_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy_attachment" "ecs_service_ec2_role" {
  name       = "ecs_service_ec2_role"
  roles      = ["${aws_iam_role.ecs_instance_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Request a Spot fleet
resource "aws_spot_fleet_request" "gitlab_spot" {
  iam_fleet_role      = "arn:aws:iam::881584977316:role/aws-ec2-spot-fleet-tagging-role"
  spot_price          = "0.02"
  allocation_strategy = "lowestPrice"
  target_capacity     = 1
  valid_until         = "2030-12-31T23:59:59Z"

  launch_specification {
    instance_type          = "${var.spot_instance_type}"
    ami                    = "${var.spot_ami}"
    spot_price             = "${var.spot_max_price}"
    availability_zone      = "${var.region}c"
    subnet_id              = "${var.subnet_gitlab_id}"
    vpc_security_group_ids = ["${var.security_group_gitlab_id}"]
    key_name               = "${var.spot_key_pair_name}"
    user_data              = "${file("${path.module}/data/user_data.sh")}"
    iam_instance_profile   = "${aws_iam_instance_profile.ecs_instance_profile.name}"

    root_block_device {
      volume_size           = "20"
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }
}

# CONTAINER

resource "aws_lb_target_group" "gitlab" {
  name     = "gitlab"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_gitlab_id}"

  health_check {
    path                = "/users/sign_in"
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 60
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "gitlab"
  }
}

resource "aws_lb" "gitlab" {
  name               = "gitlab"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_gitlab_id}"]
  subnets            = ["${var.subnet_gitlab_id}", "${var.subnet_b_gitlab_id}"]

  enable_deletion_protection = true

  tags = {
    Name = "gitlab"
  }
}

resource "aws_lb_listener" "gitlab" {
  load_balancer_arn = "${aws_lb.gitlab.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.gitlab.arn}"
    type             = "forward"
  }
}

# Documento: https://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html
resource "aws_ecs_task_definition" "gitlab" {
  family                = "gitlab"
  container_definitions = "${file("${path.module}/data/containers.json")}"
}

resource "aws_ecs_service" "gitlab" {
  name            = "gitlab"
  cluster         = "${aws_ecs_cluster.gitlab.id}"
  task_definition = "${aws_ecs_task_definition.gitlab.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.gitlab.arn}"
    container_name   = "gitlab"
    container_port   = 80
  }

  depends_on = ["aws_lb.gitlab"]
}
