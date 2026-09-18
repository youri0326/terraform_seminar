# 実行しているAWSアカウントIDを自動取得
data "aws_caller_identity" "current" {}

# CloudWatch ロググループ（エラー防止のためTerraformで作っておく）
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/task-${var.project_prefix}"
  retention_in_days = 7
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster-${var.project_prefix}"
}
# ==============================================================================
# 1. PHP Application (ECRから取り寄せ)
# ==============================================================================
resource "aws_ecs_task_definition" "php" {
  family                   = "task-php-${var.project_prefix}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = templatefile("${path.module}/task_definition/php.json", {
    # 受講生ごとの ECR URI を自動生成！
    # 例: 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/ecr-php-tanaka-20260804:latest
    ecr_image_uri  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ecr-php-${var.project_prefix}:latest"
    db_host        = var.db_host
    db_user        = var.db_username
    db_pass        = var.db_password
    db_name        = var.db_name
    log_group_name = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_ecs_service" "php" {
  name            = "ecs-service-php-${var.project_prefix}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.php.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_php_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "php"
    container_port   = 80
  }
}

# ==============================================================================
# 2. phpMyAdmin (Public ECR / Docker Hub から直接取り寄せ)
# ==============================================================================
resource "aws_ecs_task_definition" "phpmyadmin" {
  family                   = "task-phpmyadmin-${var.project_prefix}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = templatefile("${path.module}/task_definition/phpmyadmin.json", {
    db_host        = var.db_host
    db_user        = var.db_username
    db_pass        = var.db_password
    log_group_name = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_ecs_service" "phpmyadmin" {
  name            = "ecs-service-pma-${var.project_prefix}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.phpmyadmin.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_a_id]
    security_groups  = [var.ecs_phpmyadmin_sg_id]
    assign_public_ip = true
  }
}