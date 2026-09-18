output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_php_sg_id" {
  value = aws_security_group.ecs_php.id
}

output "ecs_phpmyadmin_sg_id" {
  value = aws_security_group.ecs_phpmyadmin.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}