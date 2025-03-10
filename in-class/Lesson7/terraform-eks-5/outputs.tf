output "cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
  description = "The security group of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}