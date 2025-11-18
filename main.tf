# Get all instances with RHEL10 tag
data "aws_instances" "all_rhel10" {
  instance_tags = {
    OS = "*-RHEL10"
  }
}

# Start only stopped ones
resource "aws_ec2_instance_state" "start_stopped_rhel10" {
  for_each = toset([
    for id in data.aws_instances.all_rhel10.ids : id
    if data.aws_instances.all_rhel10.instances[index(data.aws_instances.all_rhel10.ids, id)].state == "stopped"
  ])

  instance_id = each.value
  state       = "running"
}