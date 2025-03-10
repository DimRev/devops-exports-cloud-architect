# main.tf

provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"

  tags = {
    Name        = "my-instance"
    Environment = "dev"
  }
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}