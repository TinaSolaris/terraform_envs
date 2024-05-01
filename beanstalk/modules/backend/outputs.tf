output "backend_elastic_beanstalk_url" {
  value = aws_elastic_beanstalk_environment.backend.cname
}