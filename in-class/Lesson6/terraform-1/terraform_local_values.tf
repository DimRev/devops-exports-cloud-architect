# provider "aws" {
#   region = "us-east-1"
# }

# locals {
#   common_tags = {
#     Name = "Example"
#     Environment = "Production"
#     Owner       = "DevOps Team"
#   }
# }
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "t2.micro"

#   tags = local.common_tags
# }

# resource "aws_instance" "db" {
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "t2.micro"

#   tags = local.common_tags
# }