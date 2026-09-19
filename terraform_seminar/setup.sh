#!/bin/bash
# ==========================================================
# 第3章：演習の準備
# ==========================================================
# ------------------------------
# 3-5. AWS CLIのインストール
# ------------------------------
# ①AWS CLIのインストール
#公式サイトからインストーラーのダウンロード
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

#解凍用のzipコマンドのインストール
sudo apt install unzip

#zipファイルの解凍
unzip awscliv2.zip

#CLIのインストール
sudo ./aws/install

#インストールの確認
aws --version

#④AWS CLIでAWSへログイン
aws configure

# ------------------------------
# 3-6. Terraformのインストール
# ------------------------------

#①インストール準備
##パッケージ管理システムの更新
sudo apt update

##必要な前提ツールのインストール
sudo apt install -y gnupg wget

#②HashiCorp GPG鍵の取得と登録
wget -O- https://apt.releases.hashicorp.com/gpg \
| sudo gpg --dearmor \
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg

#③HashiCorp公式リポジトリの追加
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

#④Terraformのインストール
##パッケージ管理システムの更新
sudo apt update

##Terraformのインストール
sudo apt install -y terraform

###Terraformのインストール・バージョン確認
terraform -version



# ==========================================================
# アクセスキーの入力を求められるので、先ほどコピーした内容を元に次の通りに入力ください。
# AWS Access Key ID [None]:アクセスキーIDを入力
# AWS Secret Access Key [None]:シークレットアクセスキーを入力
# Default region name [None]: 「ap-northeast-1」
# Default output format [None]: 「json」
# ==========================================================



# ==========================================================
# 第4章 TerraformによるEC2、RDSの環境構築
# ==========================================================
#1. 演習準備
##1-1 terraform.tfvarsのプレフィックスの修正
##1-2 ディレクトリの移動
cd /mnt/c/terraform_seminar/chapter04

#2. Terraformの作業ディレクトリの初期化
terraform init

#3. コードの整形
terraform fmt

#4. 構文・文法ミスの確認
terraform validate

#5. 作成・変更内容の確認
terraform plan

#6. AWSリソースの作成
terraform apply

#7. リソース情報の出力
terraform output

#8. 動作確認

#9. AWSリソースの削除
terraform destroy


# ==========================================================
# 第5章 TerraformでVPCインフラの環境構築
# ==========================================================
#1. 演習準備
##1-1 terraform.tfvarsのプレフィックスの修正
##1-2 ディレクトリの移動
cd /mnt/c/terraform_seminar/chapter05

#2. Terraformの作業ディレクトリの初期化
terraform init

#3. コードの整形
terraform fmt

#4. 構文・文法ミスの確認
terraform validate

#5. 作成・変更内容の確認
terraform plan

#6. AWSリソースの作成
terraform apply

#7. リソース情報の出力
terraform output

#8. 動作確認

#9. AWSリソースの削除
terraform destroy





# ------------------------------
# 第6章 TerraformによるALB/ECSの環境構築
# ------------------------------
# ------------------------------
# 演習1：ECRの環境準備
# ------------------------------

# ------------------------------
# ⓪事前準備
# ------------------------------
# ユーザー名を変数に格納
# 氏名（例: Yamada）
USER_NAME="<氏名>" 
# 日付（例: 1019）
DATE="<日付>" 
USER_NAME_DATE="${USER_NAME}-${DATE}" 

#リージョンを変数に格納 （※デプロイするリージョンに合わせて修正してください）
REGION="ap-northeast-1" 

#アカウントIDの指定
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

#作成するECR名の登録
PHP_REPO_NAME="ecr-php-${USER_NAME_DATE}"
PMA_REPO_NAME="ecr-phpmyadmin-${USER_NAME_DATE}" 
PHP_APACHE_REPO_NAME="ecr-php-apache-${USER_NAME_DATE}"

# ECRへのログイン
aws ecr get-login-password --region ${REGION} | \
docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

#作業ディレクトリへ移動
cd /mnt/c/terraform_seminar/chapter06

# ------------------------------
# ① ECRの作成
# ------------------------------
# PHP専用のECRを作成する
aws ecr create-repository --repository-name ${PHP_REPO_NAME} --region ${REGION}

# phpMyAdmin専用のECRを作成する
aws ecr create-repository --repository-name ${PMA_REPO_NAME} --region ${REGION}

# PHP-Apache専用のECRを作成する
aws ecr create-repository --repository-name ${PHP_APACHE_REPO_NAME} --region ${REGION}


# ------------------------------
# ② Dockerイメージのプル
# ------------------------------
#phpMyAdminイメージのプル
docker pull phpmyadmin/phpmyadmin:5.2.1

#PHP-Apacheイメージのプル
docker pull php:8.1-apache

# ------------------------------
# ③ phpMyAdminイメージのプッシュ
# ------------------------------
# phpMyAminイメージをECRへタグ付け
docker tag phpmyadmin/phpmyadmin:5.2.1 ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PMA_REPO_NAME}:5.2.1

# phpMyAdminイメージのプッシュ
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PMA_REPO_NAME}:5.2.1

# ==========================================================
# ④ PHP-Apacheイメージのプッシュ (リポジトリ名: ecr-php-apache...)
# ==========================================================
# PHP-ApacheイメージをECRへタグ付け
docker tag php:8.1-apache ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PHP_APACHE_REPO_NAME}:8.1-apache

# PHP-Apacheイメージのプッシュ
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PHP_APACHE_REPO_NAME}:8.1-apache


# ==========================================================
# ⑤ PHPイメージの作成
# ==========================================================
docker build --build-arg ACCOUNT_ID=${ACCOUNT_ID} --build-arg REGION=${REGION} --build-arg ECR_REPO_PHP_Apache=${PHP_APACHE_REPO_NAME} -t ${PHP_REPO_NAME}:latest ./ecr

# ==========================================================
# ⑥ PHPイメージのプッシュ
# ==========================================================
#PHPイメージをECRへタグ付け
docker tag ${PHP_REPO_NAME}:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PHP_REPO_NAME}:latest

#PHPイメージのプッシュ
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PHP_REPO_NAME}:latest

# ------------------------------
# 演習2：ALB/ECSのインフラ環境構築
# ------------------------------
#1. 演習準備
##1-1 terraform.tfvarsのプレフィックスの修正
##1-2 ディレクトリの移動
cd /mnt/c/terraform_seminar/chapter06/terraform

#2. Terraformの作業ディレクトリの初期化
terraform init

#3. コードの整形(各子階層も含む)
terraform fmt -recursive

#4. 構文・文法ミスの確認
terraform validate

#5. 作成・変更内容の確認
terraform plan

#6. AWSリソースの作成
terraform apply

#7. リソース情報の出力
terraform output

#8. 動作確認
##8-1 データ登録
###8-1-1 phpMyAdmin用のECSのパブリックIPアドレスを確認
# 氏名（例: Yamada）
USER_NAME="<氏名>" 
# 日付（例: 1019）
DATE="<日付>" 
USER_NAME_DATE="${USER_NAME}-${DATE}" 

# phpMyAdmin用のECSのIPアドレスを確認
aws ecs list-tasks \
  --cluster ecs-cluster-${USER_NAME_DATE} \
  --service-name ecs-service-pma-${USER_NAME_DATE} \
  --query 'taskArns[0]' \
  --output text | \
xargs -I {} aws ecs describe-tasks \
  --cluster ecs-cluster-${USER_NAME_DATE} \
  --tasks {} \
  --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
  --output text | \
xargs -I {} aws ec2 describe-network-interfaces \
  --network-interface-ids {} \
  --query 'NetworkInterfaces[0].Association.PublicIp' \
  --output text


#9. AWSリソースの削除
##9-1 リソースの削除
terraform destroy

##9-2 ECRの削除
###9-2-1 環境変数の登録
####9-2-1-1 ユーザ名の指定
# 氏名（例: TaroYamada ※半角英字）
USER_NAME="<氏名>" 
# 日付（例: 1019）
DATE="<日付>" 
USER_NAME_DATE="${USER_NAME}-${DATE}" 
####9-2-1-2 リージョンの指定
REGION=ap-northeast-1


###9-2-2 phpMyAdmin用のECRの削除
aws ecr delete-repository \
  --repository-name ecr-phpmyadmin-${USER_NAME_DATE} \
  --force \
  --region ${REGION} || echo "ECR ecr-phpmyadmin-${USER_NAME_DATE} not found"

###9-2-3 PHP用のECRの削除
aws ecr delete-repository \
  --repository-name ecr-php-${USER_NAME_DATE} \
  --force \
  --region ${REGION} || echo "ECR ecr-php-${USER_NAME_DATE} not found"

###9-2-4 PHP-Apache用のECRの削除
aws ecr delete-repository \
  --repository-name ecr-php-apache-${USER_NAME_DATE} \
  --force \
  --region ${REGION} || echo "ECR ecr-php-apache-${USER_NAME_DATE} not found"
