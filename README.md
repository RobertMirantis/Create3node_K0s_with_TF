# Create3node_K0s_with_TF
Create a 3 node K0s cluster for demo purposes with Terraform

Simply create a 3 node (1 master, 2 workernodes) K0s cluster with Terraform (TF).

1) Create an simple EC2 Instance
2) Install AWS CLI (if needed)
3) Change your ~/.aws/credentials with your current (today) credentials
4) Put the AWS keypair file in ~/.ssh/  + Remember the name
5) Install Terraform (if needed)
6) Unpack zip file
7) Look into main.tf and see if there are naming conventions you want to change (like seach for RoHa... ;-)
8) Change the variable pointing to (my) AWS keypair
9) Run terraform
   terraform init
   terraform apply
   terraform destroy

Want to recreate quick : terraform destroy --auto-approve ; terraform apply --auto-approve

10) cat scripts/k0s.config = kubeconfig.yaml to add cluster to kubeconfig/Lens

K0s script normally ready within 3 minutes.
