# ---------------------------------------------
# EC2 Instance (Public Subnet)
# ---------------------------------------------

# Amazon Linux 2023 最新AMI取得
data "aws_ami" "amazonlinux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # templatefile を使って RDS の接続アドレスを注入
  user_data = templatefile("${path.module}/userdata.tftpl", {
    db_host = aws_db_instance.db.address
    db_name = aws_db_instance.db.db_name
    db_user = aws_db_instance.db.username
    db_pass = aws_db_instance.db.password
  })

  tags = {
    Name = "web-server-${var.project_prefix}"
  }
}