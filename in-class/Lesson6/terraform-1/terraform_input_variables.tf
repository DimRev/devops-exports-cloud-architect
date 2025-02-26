# provider "aws" {
#   region = "us-east-1"
# }
# variable "enable_monitoring" {
#   type        = bool
#   default     = false
#   description = "Enable or disable monitoring"
# }
# resource "aws_instance" "example" {
#   ami           = "ami-04b4f1a9cf54c11d0"
#   instance_type = "t2.micro"
#   monitoring = var.enable_monitoring
# }