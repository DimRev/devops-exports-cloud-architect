provider "aws" {
  region = "us-east-1"
}
variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "List of availability zones"
}
resource "aws_instance" "example" {
  count         = length(var.availability_zones)
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  availability_zone = element(var.availability_zones, count.index)
}