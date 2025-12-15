output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "active_color" {
  value = var.active_color
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_endpoint" {
  value = module.db.db_endpoint
}
