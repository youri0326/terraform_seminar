variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_prefix" {
  description = "リソース識別のための接頭辞（例: suzuki-0804）"
  type        = string
  default     = "suzuki-0804"
}

variable "db_password" {
  description = "RDSデータベースの管理者パスワード"
  type        = string
  sensitive   = true
  default     = "Password1234"
}

variable "db_username" {
  description = "RDSデータベースの管理者ユーザー名"
  type        = string
  default     = "admin"
}

variable "db_name" {
  description = "作成する初期データベース名"
  type        = string
  default     = "sampledb"
}