# 1. ネットワーク
module "network" {
  source         = "./network"
  aws_region     = var.aws_region
  project_prefix = var.project_prefix
}

# 2. セキュリティグループ
module "security_group" {
  source         = "./security_group"
  vpc_id         = module.network.vpc_id
  project_prefix = var.project_prefix
}

# 3. IAM
module "iam" {
  source         = "./iam"
  project_prefix = var.project_prefix
}

# 4. ALB
module "alb" {
  source            = "./alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security_group.alb_sg_id
  project_prefix    = var.project_prefix
}

# 5. RDS
module "rds" {
  source             = "./rds"
  private_subnet_ids = module.network.private_subnet_ids
  db_sg_id           = module.security_group.db_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  project_prefix     = var.project_prefix
}

# 6. ECS
module "ecs" {
  source               = "./ecs"
  public_subnet_a_id   = module.network.public_subnet_a_id
  private_subnet_ids   = module.network.private_subnet_ids
  ecs_php_sg_id        = module.security_group.ecs_php_sg_id
  ecs_phpmyadmin_sg_id = module.security_group.ecs_phpmyadmin_sg_id
  target_group_arn     = module.alb.target_group_arn
  execution_role_arn   = module.iam.ecs_execution_role_arn
  db_host              = module.rds.rds_address
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  project_prefix       = var.project_prefix
  aws_region           = var.aws_region
}