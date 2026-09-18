output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "phpmyadmin_public_ip_cmd" {
  description = "Run this command to get phpMyAdmin Public IP"
  value       = "aws ecs list-tasks --cluster ecs-cluster-${var.project_prefix} --service-name ecs-service-pma-${var.project_prefix} --query 'taskArns[0]' --output text | xargs -I {} aws ecs describe-tasks --cluster ecs-cluster-${var.project_prefix} --tasks {} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text"
}