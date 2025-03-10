# main.tf

provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  count         = var.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  availability_zone = element(var.availability_zones, count.index)

  tags = var.instance_tags
}

output "instance_public_ips" {
  value = aws_instance.example[*].public_ip
}