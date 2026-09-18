output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}
output "rds_address" {
  value = aws_db_instance.db.address
}