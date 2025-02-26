# provider "aws" {
#   region = "us-east-1"
# }

# # Data source to get the latest Amazon Linux 2 AMI
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# # Use the retrieved AMI in an EC2 instance
# resource "aws_instance" "example" {
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "t2.micro"
# }

# output "instance_ip" {
#   value = aws_instance.example.public_ip
# }