# resource "aws_instance" "web" {
#   ami = var.ami
#   instance_type = var.instance_type
#   lifecycle {
#     create_before_destroy = true
#     prevent_destroy = true
#     ignore_changes = [ ens_block_device ]
#   }
# }