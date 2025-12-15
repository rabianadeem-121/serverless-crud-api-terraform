variable "key_name" {
  description = "Name of the EC2 key pair to attach to the instance (must exist in the AWS region)"
  type        = string
}
// ...existing code...
variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default = "appuser"
}

variable "db_password" {
  description = "Master password for the RDS instance (sensitive)"
  type        = string
  sensitive   = true
}