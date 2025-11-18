# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Data source to get all instances in the region
data "aws_instances" "all_instances" {
  instance_state_names = ["stopped", "running"] # Include both to find our target instances
}

# Data source to get details about each instance
data "aws_instance" "instance_details" {
  for_each = toset(data.aws_instances.all_instances.ids)
  
  instance_id = each.value
}

# Filter instances to find those with "RHEL10" in the Name tag
locals {
  rhel10_instances = {
    for id, instance in data.aws_instance.instance_details :
    id => instance
    if can(instance.tags["Name"]) && length(regexall("RHEL10", instance.tags["Name"])) > 0
  }
}

# Start the RHEL10 instances
resource "aws_ec2_instance_state" "start_rhel10_instances" {
  for_each = local.rhel10_instances

  instance_id = each.key
  state       = "running"
}

# Output the instances that will be started
output "rhel10_instances_to_start" {
  description = "List of RHEL10 instances that will be started"
  value = [
    for id, instance in local.rhel10_instances : {
      instance_id    = id
      instance_name  = instance.tags["Name"]
      current_state  = instance.instance_state
    }
  ]
}