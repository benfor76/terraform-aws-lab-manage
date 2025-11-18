# Data source to find the instances
data "aws_ec2_instances" "rhel10_instances" {
  instance_state_names = ["running", "stopped"] # Search in both running and stopped states
  filter {
    name   = "tag:Name"
    values = ["*RHEL10*"] # Using a wildcard to match any name containing 'RHEL10'
  }
}

# Resource to ensure each found instance is started
resource "aws_ec2_instance_state" "start_rhel10" {
  for_each = toset(data.aws_ec2_instances.rhel10_instances.ids)
  instance_id = each.value
  state       = "running"
}