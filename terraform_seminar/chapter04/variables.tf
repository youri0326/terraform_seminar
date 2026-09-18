variable "instance_type" {
  description = "EC2インスタンスタイプ"
  type        = string
  default     = "t3.micro"
}

variable "project_prefix" {
  description = "受講者識別用のプレフィックス（例: suzuki-0804）"
  type        = string
  default     = "suzuki-0804"
}

variable "db_password" {
  description = "RDSデータベースの管理者パスワード"
  type        = string
  sensitive   = true # ログ等にパスワードが平文表示されるのを防ぐ設定
  default     = "Password1234"
}