# modules/ec2_instance/variables.tf

variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance to create"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
}