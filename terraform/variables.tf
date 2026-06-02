variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to use for SSH"
  type        = string
  default     = "vockey"
}
