provider "aws" {
  region = var.aws_region
}

# Data source to find the AAPPG-RHEL10 instance
data "aws_instances" "aappg_rhel10" {
  filter {
    name   = "tag:Name"
    values = ["AAPPG-RHEL10"]
  }

  filter {
    name   = "instance-state-name"
    values = ["stopped"]
  }
}

# Data source to find all other RHEL10 instances (excluding AAPPG-RHEL10)
data "aws_instances" "other_rhel10" {
  filter {
    name   = "tag:Name"
    values = ["*-RHEL10"]  # Matches any name ending with -RHEL10
  }

  filter {
    name   = "instance-state-name"
    values = ["stopped"]
  }
}

# Local values to process instance IDs
locals {
  # Get AAPPG-RHEL10 instance ID (first one if multiple found)
  aappg_instance_id = length(data.aws_instances.aappg_rhel10.ids) > 0 ? data.aws_instances.aappg_rhel10.ids[0] : null
  
  # Get other RHEL10 instances, excluding AAPPG-RHEL10
  other_instance_ids = [
    for id in data.aws_instances.other_rhel10.ids :
    id if id != local.aappg_instance_id
  ]
}

# Start AAPPG-RHEL10 instance first
resource "aws_ec2_instance_state" "start_aappg" {
  count = local.aappg_instance_id != null ? 1 : 0

  instance_id = local.aappg_instance_id
  state       = "running"
}

# Wait for AAPPG-RHEL10 to be running before starting others
resource "time_sleep" "wait_for_aappg" {
  count = local.aappg_instance_id != null ? 1 : 0

  depends_on = [aws_ec2_instance_state.start_aappg]

  create_duration = "60s"  # Wait 60 seconds for instance to fully start
}

# Start all other RHEL10 instances after AAPPG-RHEL10 is running
resource "aws_ec2_instance_state" "start_other_instances" {
  for_each = toset(local.other_instance_ids)

  instance_id = each.value
  state       = "running"

  depends_on = [time_sleep.wait_for_aappg]
}