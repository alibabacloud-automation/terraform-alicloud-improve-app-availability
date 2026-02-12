variable "common_name" {
  description = "Common name prefix for all resources"
  type        = string
  default     = "improve-app-availability"
}

variable "scale_up_time" {
  description = "Scheduled time for scaling up. Format: YYYY-MM-DDTHH:mmZ"
  type        = string
  default     = null
}

variable "scale_down_time" {
  description = "Scheduled time for scaling down. Format: YYYY-MM-DDTHH:mmZ"
  type        = string
  default     = null
}