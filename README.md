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

Terraform은 이 디렉터리의 모든 `.tf` 파일을 하나의 구성으로 읽습니다.
리소스는 종류별 파일로 나누고, `output`은 어느 리소스의 것이든 `outputs.tf`에만 정의합니다.

| 파일            | 역할                                                       |
| --------------- | ---------------------------------------------------------- |
| `provider.tf`   | Terraform 설정, AWS provider, S3 backend                   |
| `backend.tf`    | 원격 상태용 S3 버킷(버전 관리/암호화)과 DynamoDB 잠금 테이블 |
| `variables.tf`  | 입력 변수 정의                                             |
| `local.tf`      | 프로젝트명, 공통 태그, 인스턴스 타입 map                   |
| `data.tf`       | Availability Zone과 VPC 조회                               |
| `vpc.tf`        | VPC                                                        |
| `subnet.tf`     | `for_each` 로 생성하는 public / private subnet             |
| `routing.tf`    | Internet Gateway, route table 및 subnet association        |
| `compute.tf`    | EC2 인스턴스 (`logs`, `media`, `backups`, `csjin_ec2`)     |
| `outputs.tf`    | 실제 리소스 output                                         |
| `examples.tf`   | 자료형/문자열 함수/for 식 학습용 output                    |
| `ex-net/`       | 독립 실행 가능한 별도 스택 (VPC + ALB + ASG + RDS + S3)    |
| `_reference/`   | 구성에 포함되지 않는 참고 자료                             |

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
이 프로젝트의 `backend.tf`가 해당 리소스를 선언하므로, 새 환경에서는 `provider.tf`의 `backend` 블록을 주석 처리하고 로컬 state로 `backend.tf`만 먼저 apply한 뒤 초기화하세요.

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

### 현재 루트 state 가 깨져 있습니다

`terraform state list` 가 아래 오류를 반환합니다.

```text
state data in S3 does not have the expected content.
Calculated checksum:
Stored checksum:     871712608935ec8a9ca91848014ab6ba
```

S3 의 `terraform.tfstate` 객체는 비어 있는데 DynamoDB 에 이전 Digest 가 남아 있는 상태입니다.
먼저 S3 에 실제 state 가 남아 있는지 확인하세요.

```bash
aws s3api list-object-versions   --bucket bipa17-std15-terraform-state-bucket   --prefix terraform.tfstate
```

- **버전이 남아 있으면**: 정상 버전을 복원한 뒤 다시 `terraform plan` 을 실행합니다.
- **state 를 버려도 되면**: DynamoDB 의 Digest 항목만 삭제합니다.

```bash
aws dynamodb delete-item   --table-name bipa17-std15-terraform-state-lock   --key '{"LockID":{"S":"bipa17-std15-terraform-state-bucket/terraform.tfstate-md5"}}'
```

> Digest 를 삭제하면 Terraform 이 state 를 빈 상태로 인식합니다.
> AWS 에 리소스가 남아 있는 경우 재생성을 시도하므로, 먼저 `terraform import` 계획을 세우세요.

state 를 복구한 뒤 `provider.tf` 의 deprecated 된 `dynamodb_table` 을 `use_lockfile = true` 로 교체하고
`terraform init -reconfigure` 를 실행하세요. (`ex-net/` 은 이미 교체 완료)

## GitHub

저장소: https://github.com/totorosi/terraform-std15
