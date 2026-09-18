# ALB の DNS名（PHP アプリ確認用）
output "alb_dns_name" {
  description = "Webアプリケーションの接続用ALB DNS"
  value       = "http://${module.alb.alb_dns_name}"
}

# phpMyAdmin 確認用（AWS CLI コマンドを提示する場合）
output "phpmyadmin_public_ip_cmd" {
  description = "Run this command in terminal to get phpMyAdmin Public IP"
  value       = module.ecs.phpmyadmin_public_ip_cmd
}

output "rds_endpoint" {
  description = "RDS接続エンドポイント"
  value       = module.rds.rds_endpoint
}