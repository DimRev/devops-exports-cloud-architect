resource "aws_instance" "example" {
  count = 3

  dynamic "ebs_block_device" {
    for_each = {
      "example1" = "/dev/sdj"
      "example2" = "/dev/sdh"
      "example3" = "/dev/sdi"
    }
    content {
      device_name = ebs_block_device.value
      volume_type = "gp3"
      volume_size = 50
    }
  }

  instance_type = "t2.micro"
  ami           = "ami-0c55b159cbfafe1f0"
}