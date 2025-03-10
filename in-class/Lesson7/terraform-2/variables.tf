# variables.tf

variable "region" {
  type        = string
  description = "The AWS region where the resources will be created"
  default     = "us-west-2"
}

variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to create"
  default     = "t2.micro"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to launch"
  default     = 2
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags to apply to each instance"
}
