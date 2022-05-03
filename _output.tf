output "endpoint" {
  value = var.db_type == "rds" ? aws_db_instance.rds_db[0].endpoint : aws_rds_cluster.aurora_cluster[0].endpoint
}

output "identifier" {
  value = var.db_type == "rds" ? aws_db_instance.rds_db[0].identifier : aws_rds_cluster.aurora_cluster[0].cluster_identifier
}

output "rds_sg" {
  value = aws_security_group.rds_db.id
}