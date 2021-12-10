# Build AWS Infrastructure

Create AWS account

Define AWS Credentials (Access Keys)

```bash
cd terraform-prov-aws
./run.sh (Create Buckets for terraform Backend)
terraform init
terraform plan
terraform apply --auto-approve
```

# Build Kubernetes Environment

```bash
cd ansible-k8s
./run.sh
```



