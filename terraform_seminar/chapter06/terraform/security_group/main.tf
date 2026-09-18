# 1. ALB用SG
resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.project_prefix}"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg-${var.project_prefix}" }
}

# 2. PHP用ECS SG (Private Subnet用: ALBからのみアクセス許可)
resource "aws_security_group" "ecs_php" {
  name        = "ecs-php-sg-${var.project_prefix}"
  description = "Allow HTTP from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs-php-sg-${var.project_prefix}" }
}

# 3. phpMyAdmin用ECS SG (Public Subnet用: 外部から直接アクセス許可)
resource "aws_security_group" "ecs_phpmyadmin" {
  name        = "ecs-phpmyadmin-sg-${var.project_prefix}"
  description = "Allow direct HTTP access for phpMyAdmin"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs-phpmyadmin-sg-${var.project_prefix}" }
}

# 4. RDS用SG (ecs_php と ecs_phpmyadmin の両方からのMySQL 3306接続を許可)
resource "aws_security_group" "db" {
  name        = "db-sg-${var.project_prefix}"
  description = "Allow MySQL from PHP and phpMyAdmin ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from ECS tasks"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs_php.id,
      aws_security_group.ecs_phpmyadmin.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg-${var.project_prefix}" }
}