variable "env" {
  description = "Environment"
  type        = string
}

variable "aws_endpoint" {
  description = "AWS endpoint"
  type        = string
  default     = ""
}

variable "repo_root" {
  description = "Root of the repository"
  type        = string
}
