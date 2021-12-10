variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}

variable "default_instance" {
  description = "default_instance"
  default     = "t3.medium"
  type        = string
}