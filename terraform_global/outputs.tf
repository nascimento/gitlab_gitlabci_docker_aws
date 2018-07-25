output "subnet_gitlab_id" {
  value = "${aws_subnet.gitlab.id}"
}

output "subnet_b_gitlab_id" {
  value = "${aws_subnet.gitlab_b.id}"
}

output "security_group_gitlab_id" {
  value = "${aws_security_group.gitlab.id}"
}

output "vpc_gitlab_id" {
  value = "${aws_vpc.gitlab.id}"
}
