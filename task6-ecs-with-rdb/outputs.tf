output "alb_dns_name" {
  value = aws_lb.ecs_lb[*].dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.my_db.endpoint
}

output "ecs_cluster" {
  value = aws_ecs_cluster.ecs_cluster.name
}
