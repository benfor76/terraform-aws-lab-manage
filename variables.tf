variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "operation" {
  description = "Operation to perform: start or stop"
  type        = string
  default     = "start"
  
  validation {
    condition     = contains(["start", "stop"], var.operation)
    error_message = "Operation must be either 'start' or 'stop'."
  }
}

variable "wait_time" {
  description = "Time to wait between operations (in seconds)"
  type        = number
  default     = 60
}