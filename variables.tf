variable "aws_region" {
  description = "AWS region where instances are located"
  type        = string
  default     = "us-east-2"
}

variable "wait_time_seconds" {
  description = "Time to wait between starting AAPPG-RHEL10 and other instances"
  type        = number
  default     = 60
}