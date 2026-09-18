resource "aws_lb" "main" {
  name               = "alb-${var.project_prefix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = { Name = "alb-${var.project_prefix}" }
}

# Target Group: PHP App (Port 80)
resource "aws_lb_target_group" "php" {
  name        = "tg-php-${var.project_prefix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = { Name = "tg-php-${var.project_prefix}" }
}

# Listener: Port 80 -> PHP App
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.php.arn
  }
}
