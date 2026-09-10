# ex-net

독립 실행 가능한 AWS 실습 스택입니다. (`sa-east-1` 리전)

## 파일 구성

| 파일 | 내용 |
| --- | --- |
| `provider.tf` | terraform 블록(required_providers, S3 backend), AWS provider |
| `variables.tf` | 모든 입력 변수 |
| `terraform.tfvars` | 환경별 변수 값 (git 에서 제외됨) |
| `terraform.tfvars.example` | tfvars 작성용 템플릿 (커밋 대상) |
| `local.tf` | locals (사용 AZ 계산, user_data 렌더링) |
| `data.tf` | 모든 data source |
| `vpc.tf` | VPC |
| `subnet.tf` | public / private subnet |
| `routing.tf` | Internet Gateway, NAT Gateway, route table |
| `security.tf` | Security Group, Network ACL |
| `compute.tf` | 단독 EC2 인스턴스 |
| `alb.tf` | 외부 ALB, target group, listener |
| `alb_internal.tf` | 내부 ALB, target group, listener |
| `asg.tf` | Launch Template, Auto Scaling Group, 스케줄 |
| `mysql.tf` | 단독 RDS(MySQL) 및 DB subnet group |
| `mysql_cluster.tf` | Aurora MySQL 클러스터 + Secrets Manager 자동 교체 |
| `secretsmanager.tf` | DB 비밀번호 생성 및 Secrets Manager 저장 |
| `s3.tf` | 정적 웹사이트용 S3 버킷 |
| `outputs.tf` | 모든 output |
| `user_data.sh` | EC2 / Launch Template 공용 부트스트랩 스크립트 |

리소스는 `vpc.tf` / `subnet.tf` / `routing.tf` / `security.tf` 처럼 종류별로 나누고,
`output` 은 어느 리소스의 것이든 전부 `outputs.tf` 에만 정의합니다.

## 포함 리소스

- VPC 1개
- Availability Zone 3개에 public/private subnet 각 3개
- Internet Gateway와 NAT Gateway
- public/private route table 및 subnet association
- SSH, external ALB, internal ALB, EC2, MySQL용 Security Group
- public subnet용 Network ACL
- nginx EC2 인스턴스 + 외부 ALB + Auto Scaling Group
- VPC 내부 진입점용 internal ALB (private subnet)
- RDS MySQL (비밀번호는 `random_password` 로 생성해 Secrets Manager 에 저장)
- Aurora MySQL 클러스터 + 비밀번호 자동 교체(rotation) Lambda
- 정적 웹사이트 호스팅용 S3 버킷

## 실행

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

SSH를 사용하려면 `terraform.tfvars`에 접속할 IP를 제한해서 지정하세요.

```hcl
admin_cidr_blocks = ["203.0.113.10/32"]
```

## DB 접속 정보 확인

비밀번호는 코드에 하드코딩하지 않습니다. apply 후 아래로 확인하세요.

```bash
terraform output -raw mysql_password
aws secretsmanager get-secret-value --secret-id "$(terraform output -raw mysql_secret_arn)" --query SecretString --output text
```

## 정리

NAT Gateway, Elastic IP, ALB, RDS는 AWS 비용이 발생합니다. 실습 후에는 삭제하세요.

```bash
terraform destroy
```
