terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# 1. Find all instances with Name tag containing "RHEL10"
data "aws_instances" "rhel10" {
  filter {
    name   = "tag:Name"
    values = ["*-RHEL10"]
  }
}

# 2. Start them using AWS CLI via a null_resource
resource "null_resource" "start_rhel10_instances" {
  # Rerun this resource if the set of instance IDs changes
  triggers = {
    instance_ids = join(",", data.aws_instances.rhel10.ids)
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      if [ "${join(" ", data.aws_instances.rhel10.ids)}" != "" ]; then
        echo "Starting instances: ${join(" ", data.aws_instances.rhel10.ids)}"
        aws ec2 start-instances \
          --region us-east-2 \
          --instance-ids ${join(" ", data.aws_instances.rhel10.ids)}
      else
        echo "No instances found with Name tag matching *RHEL10*"
      fi
    EOT
  }
}
