provider "aws" {
  region = "us-east-1"
}

# 1. Get all EC2 instances with Name tag containing "RHEL10"
data "aws_instances" "rhel10" {
  filter {
    name   = "tag:Name"
    values = ["*RHEL10*"]
  }
}

# 2. Start the instances using SSM Automation
resource "aws_ssm_automation_execution" "start_rhel10" {
  document_name = "AWS-StartEC2Instance"

  parameters = {
    InstanceId = data.aws_instances.rhel10.ids
  }
}
