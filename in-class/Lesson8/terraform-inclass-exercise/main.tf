provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "web-service-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "instance_public_ips" {
  value = aws_instance.web[*].public_ip
}
