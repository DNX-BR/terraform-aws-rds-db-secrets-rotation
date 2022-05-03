resource "aws_db_subnet_group" "rds_subnet_group" {
  count      = var.create_db_subnet_group ? 1 : 0
  name       = var.db_subnet_group_id
  subnet_ids = var.db_subnet_group_subnet_ids

  tags = {
    Name = var.db_subnet_group_id
  }
}