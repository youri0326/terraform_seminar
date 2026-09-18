# ---------------------------------------------
# RDS Instance (Private Subnet)
# ---------------------------------------------

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group-${var.project_prefix}"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "db-subnet-group-${var.project_prefix}" }
}

# RDS Parameter Group (SSLオフ・ホストブロック回避)
resource "aws_db_parameter_group" "main" {
  name   = "rds-pg-${var.project_prefix}"
  family = "mariadb10.11"

  parameter {
    name  = "require_secure_transport"
    value = "OFF"
  }

  parameter {
    name  = "max_connect_errors"
    value = "10000"
  }

  tags = {
    Name = "rds-pg-${var.project_prefix}"
  }
}

# RDS MySQL
resource "aws_db_instance" "db" {
  identifier             = "rds-mysql-${var.project_prefix}"
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "mariadb"
  engine_version         = "10.11"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true

  parameter_group_name = aws_db_parameter_group.main.name

  tags = { Name = "rds-mysql-${var.project_prefix}" }
}