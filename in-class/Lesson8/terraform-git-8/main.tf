terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = "token_goes_here"
}

resource "github_repository" "terraform-example-dimrev" {
  name = "terraform-example"
  description = "My repo"
  visibility = "public"
}