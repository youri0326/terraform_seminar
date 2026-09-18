# ------------------------------------------------------------------------------
# Network & Security
# ------------------------------------------------------------------------------
variable "public_subnet_a_id" {
  type        = string
}

variable "private_subnet_ids" {
  type        = list(string)
}

variable "ecs_php_sg_id" {
  type        = string
}

variable "ecs_phpmyadmin_sg_id" {
  type        = string
}

variable "target_group_arn" {
  type        = string
}

# ------------------------------------------------------------------------------
# IAM & System Config
# ------------------------------------------------------------------------------
variable "execution_role_arn" {
  type        = string
}

variable "aws_region" {
  type        = string
}

variable "project_prefix" {
  type        = string
}

# ------------------------------------------------------------------------------
# Database Settings
# ------------------------------------------------------------------------------
variable "db_host" {
  type        = string
}

variable "db_name" {
  type        = string
}

variable "db_username" {
  type        = string
}

variable "db_password" {
  type        = string
  sensitive   = true
}