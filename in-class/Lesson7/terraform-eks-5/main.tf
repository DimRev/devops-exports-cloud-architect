provider "aws" {
  region = var.region
}

# ✅ Updated VPC Module (Latest Version)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Upgrade to latest version
  name    = "eks-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}

# ✅ Updated EKS Module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.16.0"  # Latest stable version
  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_size         = var.max_size
      min_size         = var.min_size

      instance_types = ["t3.medium"]

      labels = {
        Environment = "dev"
      }
    }
  }

  cluster_endpoint_public_access = true

  tags = {
    Name = "eks-cluster"
  }
}