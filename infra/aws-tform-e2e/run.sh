cd terraform-prov-aws/

./run.sh

terraform init
terraform plan 
terraform apply --auto-approve

cd ../ansible-k8s/
./run.sh

cd ../ansible-free5gc/
./run.sh

echo "Access AWS Console to Connect to Cluster"
