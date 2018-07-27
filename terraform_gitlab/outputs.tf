output "gitlab_url" {
  value = "http://${aws_instance.gitlab.public_ip}/"
}
