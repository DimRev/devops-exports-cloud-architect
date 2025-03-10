terraform {
  backend "s3" {
    bucket         = "dimar-terraform-state-bucket-user1"
    key            = "prod/terraform.tfstate"           # Path inside the bucket
    region         = "us-east-1"
    encrypt        = true                               # Encrypt the state file
    dynamodb_table = "terraform-locking-user100"        # For state locking
  }
}