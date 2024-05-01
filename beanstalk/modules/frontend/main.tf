locals {
  frontend_app_env = {
    BACKEND_URL = var.backend_url
  }
  frontend_common_name = "${var.frontend_app_name}"
}

resource "random_pet" "ebs_bucket_name" {}

data "template_file" "frontend_ebs_config" {
  template = file("${path.module}/Dockerrun.aws.json")
}

resource "local_file" "frontend_ebs_config" {
  content  = data.template_file.frontend_ebs_config.rendered
  filename = "${path.module}/Dockerrun.aws.json"
}

resource "aws_s3_bucket" "frontend_ebs" {
  bucket = "${local.frontend_common_name}-${random_pet.ebs_bucket_name.id}"
}

resource "aws_s3_object" "frontend_ebs_deployment" {
  depends_on = [local_file.frontend_ebs_config]
  bucket     = aws_s3_bucket.frontend_ebs.id
  key        = "Dockerrun.aws.json"
  source     = "${path.module}/Dockerrun.aws.json"
  lifecycle {
    replace_triggered_by = [ local_file.frontend_ebs_config ]
  }
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  name = "LabInstanceProfile"
}

data "aws_iam_role" "existing_instance_role" {
  name = "LabRole"  # Name of the IAM role associated with the instance profile
}

# Define the Elastic Beanstalk application and environment for the frontend
resource "aws_elastic_beanstalk_application" "frontend_app" {
  name = local.frontend_common_name
}

resource "aws_elastic_beanstalk_application_version" "frontend_app_version" {
  name        = "${local.frontend_common_name}-version"
  application = aws_elastic_beanstalk_application.frontend_app.name
  bucket      = aws_s3_bucket.frontend_ebs.id
  key         = aws_s3_object.frontend_ebs_deployment.id
}

resource "aws_elastic_beanstalk_environment" "frontend" {
  name                = "${local.frontend_common_name}-env"
  application         = aws_elastic_beanstalk_application.frontend_app.name
  version_label       = aws_elastic_beanstalk_application_version.frontend_app_version.name
  solution_stack_name = "64bit Amazon Linux 2 v3.8.0 running Docker"
  tier                = "WebServer"
  wait_for_ready_timeout  = "10m"

  setting {
    name      = "InstancePort"
    namespace = "aws:cloudformation:template:parameter"
    value     = var.frontend_container_port
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = data.aws_iam_instance_profile.existing_instance_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = data.aws_iam_role.existing_instance_role.arn
  }

  dynamic "setting" {
    for_each = local.frontend_app_env
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }
}
