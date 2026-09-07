# ex-net

독립 실행 가능한 AWS 네트워크 예제입니다.

## 포함 리소스

- 1개 VPC
- Availability Zone 3개에 public/private subnet 각 3개
- Internet Gateway와 NAT Gateway
- public/private route table 및 subnet association
- SSH, external ALB, internal ALB용 Security Group
- public subnet용 Network ACL

## 실행

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

기본 설정은 `sa-east-1` 리전의 첫 3개 Availability Zone을 사용합니다.
SSH를 사용하려면 `terraform.tfvars`에 접속할 IP를 제한해서 지정하세요.

```hcl
admin_cidr_blocks = ["203.0.113.10/32"]
```

NAT Gateway와 Elastic IP는 AWS 비용이 발생할 수 있습니다. 실습 후에는 다음 명령으로 삭제하세요.

```bash
terraform destroy
```
