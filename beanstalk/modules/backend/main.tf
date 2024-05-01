locals {
  common_name = "${var.backend_app_name}"
}

resource "random_pet" "ebs_bucket_name" {}

resource "aws_s3_bucket" "ebs" {
  bucket = "${local.common_name}-${random_pet.ebs_bucket_name.id}"
}

data "template_file" "ebs_config" {
  template = file("${path.module}/Dockerrun.aws.json")
}

resource "local_file" "ebs_config" {
  content  = data.template_file.ebs_config.rendered
  filename = "${path.module}/Dockerrun.aws.json"
}

resource "aws_s3_object" "ebs_deployment" {
  depends_on = [local_file.ebs_config]
  bucket     = aws_s3_bucket.ebs.id
  key        = "Dockerrun.aws.json"
  source     = "${path.module}/Dockerrun.aws.json"
  lifecycle {
    replace_triggered_by = [ local_file.ebs_config ]
  }
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  name = "LabInstanceProfile"
}

data "aws_iam_role" "existing_instance_role" {
  name = "LabRole"  # Name of the IAM role associated with the instance profile
}

# Define the Elastic Beanstalk application and environment for the backend
resource "aws_elastic_beanstalk_application" "backend_app" {
  name = local.common_name
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "${local.common_name}-version"
  application = aws_elastic_beanstalk_application.backend_app.name
  bucket      = aws_s3_bucket.ebs.id
  key         = aws_s3_object.ebs_deployment.id
}


resource "aws_elastic_beanstalk_environment" "backend" {
  name                = "${local.common_name}-env"
  application         = aws_elastic_beanstalk_application.backend_app.name
  version_label       = aws_elastic_beanstalk_application_version.app_version.name
  solution_stack_name = "64bit Amazon Linux 2 v3.8.0 running Docker"
  tier                = "WebServer"
  wait_for_ready_timeout  = "10m"

  setting {
    name      = "InstancePort"
    namespace = "aws:cloudformation:template:parameter"
    value     = var.backend_container_port
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
}
