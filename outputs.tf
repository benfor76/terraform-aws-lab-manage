output "aappg_instance_started" {
  description = "Details of the AAPPG-RHEL10 instance that was started"
  value = local.aappg_instance_id != null ? {
    instance_id = local.aappg_instance_id
    message     = "AAPPG-RHEL10 instance started successfully"
  } : {
    instance_id = null
    message     = "No AAPPG-RHEL10 instance found in stopped state"
  }
}

output "other_instances_started" {
  description = "List of other RHEL10 instances that were started"
  value       = local.other_instance_ids
}

output "total_instances_processed" {
  description = "Summary of instances processed"
  value = {
    aappg_instances = local.aappg_instance_id != null ? 1 : 0
    other_instances = length(local.other_instance_ids)
    total_instances = (local.aappg_instance_id != null ? 1 : 0) + length(local.other_instance_ids)
  }
}