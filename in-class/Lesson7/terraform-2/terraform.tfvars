# terraform.tfvars

region = "us-east-1"

instance_type = "t3.medium"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_count = 3

instance_tags = {
  Environment = "production"
  Owner       = "admin-team"
}