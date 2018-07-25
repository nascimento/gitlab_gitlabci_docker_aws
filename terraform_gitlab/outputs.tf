output "gitlab_url" {
  value = "${aws_lb.gitlab.dns_name}"
}
