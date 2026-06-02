#!/bin/bash
set -e

echo "=== Cleaning up any existing infrastructure ==="
cd terraform
terraform init -input=false
terraform destroy -auto-approve || true

echo "=== Provisioning infrastructure with Terraform ==="
terraform apply -auto-approve

echo "=== Getting instance public IP ==="
PUBLIC_IP=$(terraform output -raw instance_public_ip)
echo "Instance IP: $PUBLIC_IP"

echo "=== Waiting for instance to be ready ==="
sleep 60

echo "=== Configuring server with Ansible ==="
cd ../ansible
cat > inventory.ini << EOF
[minecraft]
$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/labsuser.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

ansible-playbook -i inventory.ini playbook.yml

echo "=== Verifying Minecraft server ==="
nmap -sV -Pn -p T:25565 $PUBLIC_IP

echo "=== Done! Minecraft server is running at $PUBLIC_IP:25565 ==="
