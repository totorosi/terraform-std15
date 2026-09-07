# std15-terra

AWS 네트워크와 EC2 리소스를 Terraform으로 구성하는 학습용 프로젝트입니다.
Terraform은 이 디렉터리의 모든 `.tf` 파일을 하나의 구성으로 읽습니다.

## 구성 내용

- AWS 리전: `sa-east-1`
- VPC: `10.0.0.0/16`
- 서브넷: public 3개, private 3개
- 인터넷 게이트웨이 및 public/private route table
- EC2: `logs`, `media`, `backups`, `csjin_ec2`
- EC2 인스턴스 타입: 기본 `t3.micro`
- Terraform 원격 상태: S3 backend
- 상태 잠금: DynamoDB

모든 리소스에는 프로젝트와 환경을 나타내는 공통 태그가 적용됩니다.

## 파일 구성

| 파일           | 역할                                                       |
| -------------- | ---------------------------------------------------------- |
| `provider.tf`  | AWS provider와 S3 backend 설정                             |
| `main.tf`      | VPC, Internet Gateway, route table 및 subnet association   |
| `main_each.tf` | `for_each`를 사용한 서브넷과 EC2 생성, output 및 함수 예제 |
| `mian.tf`      | Terraform 상태 버킷, 버전 관리, DynamoDB 잠금 테이블       |
| `variables.tf` | 입력 변수와 자료형별 Terraform 예제                        |
| `local.tf`     | 프로젝트명과 공통 태그                                     |
| `data.tf`      | Availability Zone과 VPC 조회                               |
| `test.tf`      | 주석 처리된 `count`와 `for_each` 실습 예제                 |
| `ex-net/`      | 별도로 실행할 수 있는 간단한 VPC 예제                      |

`mian.tf`는 파일명이 오타처럼 보이지만 `.tf` 확장자를 가지므로 Terraform 구성에 포함됩니다.

## 사전 조건

- Terraform 설치
- AWS CLI 또는 환경 변수 기반 AWS 인증
- `sa-east-1` 리전에 대한 VPC, EC2, S3, DynamoDB 권한
- 원격 상태에 사용할 S3 버킷과 DynamoDB 테이블

현재 backend 설정은 다음 리소스를 사용합니다.

```text
S3 bucket: bipa17-std15-terraform-state-bucket
State key: terraform.tfstate
Region:    sa-east-1
Lock table: bipa17-std15-terraform-state-lock
```

backend는 Terraform 초기화 시점에 먼저 접근하므로 S3 버킷과 DynamoDB 테이블이 이미 존재해야 합니다.
이 프로젝트의 `mian.tf`는 해당 리소스의 선언도 포함하므로, 새 환경에서는 backend 리소스를 먼저 준비한 후 초기화해야 합니다.

## 실행 방법

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

자동 승인으로 적용하려면 다음을 사용합니다.

```bash
terraform apply -auto-approve
```

적용 후 리소스와 output을 확인합니다.

```bash
terraform state list
terraform output
```

## 상태 파일 주의사항

로컬 상태 파일과 `.terraform/` 디렉터리는 Git에 커밋하지 않습니다.
`.gitignore`에서 `*.tfstate`, `*.tfstate.*`, `.terraform/`을 제외하고 있습니다.
상태 파일에는 인프라 정보가 포함될 수 있으므로 S3 backend를 사용하고 버전 관리와 잠금을 유지해야 합니다.

현재 `provider.tf`의 `dynamodb_table` backend 옵션은 Terraform 버전에 따라 deprecated 경고가 표시될 수 있습니다.
사용 중인 Terraform 버전에 맞춰 backend 잠금 방식으로 점진적으로 변경해야 합니다.

## GitHub

저장소: https://github.com/totorosi/terraform-std15
