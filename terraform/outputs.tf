output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
output "alb_dns_name" {
  description = "The public URL to view your deployed application website"
  value       = "http://${module.alb.dns_name}"
}
