provider "aws" {
  region = var.aws_region
}

# Data source to get all EC2 instances with RHEL10 in their tags
data "aws_instances" "all_rhel10_instances" {
  instance_tags = {
    "Name" = "*RHEL10"
  }
}

# Data source to get the specific AAPPG-RHEL10 instance
data "aws_instances" "aappg_rhel10_instance" {
  instance_tags = {
    "Name" = "AAPPG-RHEL10"
  }
}

# Data source to get other RHEL10 instances (excluding AAPPG-RHEL10)
data "aws_instances" "other_rhel10_instances" {
  instance_tags = {
    "Name" = "*RHEL10"
  }
}

# Local values to separate instances
locals {
  aappg_instance_id = length(data.aws_instances.aappg_rhel10_instance.ids) > 0 ? data.aws_instances.aappg_rhel10_instance.ids[0] : null
  
  other_instance_ids = [
    for id in data.aws_instances.other_rhel10_instances.ids :
    id if id != local.aappg_instance_id
  ]
  
  # Determine current state of instances for conditional operations
  aappg_instance_state = local.aappg_instance_id != null ? data.aws_instances.aappg_rhel10_instance.instance_state_names[0] : null
}

# START OPERATION
resource "aws_ec2_instance_state" "start_aappg_rhel10" {
  count = var.operation == "start" && local.aappg_instance_id != null ? 1 : 0
  
  instance_id = local.aappg_instance_id
  state       = "running"
}

resource "time_sleep" "wait_for_aappg_running" {
  count = var.operation == "start" && local.aappg_instance_id != null ? 1 : 0
  
  depends_on = [aws_ec2_instance_state.start_aappg_rhel10]
  
  create_duration = "${var.wait_time}s"
}

resource "aws_ec2_instance_state" "start_other_rhel10_instances" {
  for_each = var.operation == "start" ? toset(local.other_instance_ids) : []
  
  instance_id = each.key
  state       = "running"

  depends_on = [time_sleep.wait_for_aappg_running]
}

# STOP OPERATION
resource "aws_ec2_instance_state" "stop_other_rhel10_instances" {
  for_each = var.operation == "stop" ? toset(local.other_instance_ids) : []
  
  instance_id = each.key
  state       = "stopped"
}

resource "time_sleep" "wait_for_others_stopped" {
  count = var.operation == "stop" ? 1 : 0
  
  depends_on = [aws_ec2_instance_state.stop_other_rhel10_instances]
  
  create_duration = "${var.wait_time}s"
}

resource "aws_ec2_instance_state" "stop_aappg_rhel10" {
  count = var.operation == "stop" && local.aappg_instance_id != null ? 1 : 0
  
  instance_id = local.aappg_instance_id
  state       = "stopped"

  depends_on = [time_sleep.wait_for_others_stopped]
}

# Outputs
output "operation" {
  description = "Current operation being performed"
  value       = var.operation
}

output "aappg_rhel10_instance_id" {
  description = "ID of the AAPPG-RHEL10 instance"
  value       = local.aappg_instance_id
}

output "other_rhel10_instance_ids" {
  description = "IDs of other RHEL10 instances"
  value       = local.other_instance_ids
}

output "total_instances" {
  description = "Total number of RHEL10 instances found"
  value       = length(data.aws_instances.all_rhel10_instances.ids)
}