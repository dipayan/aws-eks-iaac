# Amazon EKS Cluster bootstrap using Terraform

A Terraform script to create a Amazon EKS Cluster supporting multiple environments and a production-like setup along with basic bootsrapping of initial required containers for the newly created Kubernetes cluster

## Pre-requisites

Note : **Commands are all specific to CentOS 7**

  - Download & install [Terraform 3.6](https://www.terraform.io/)
```bash
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
sudo mv terraform /usr/bin/
```
  - Download & install [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl
```
  - Download & Install [Helm](https://docs.helm.sh/using_helm/#installing-helm)
```bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
tar -zxvf helm-v2.11.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/
```
  - Download & Install [Docker](https://docs.docker.com/install/linux/docker-ce/centos/) (OPTIONAL)
```bash
sudo yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce    
```

  - Download & Install [AWS CLI](https://aws.amazon.com/cli/)
```bash
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install awscli --upgrade --user
```

   - Login to your Amazon console and create an S3 Bucket where you will be storing your terraform state files , you can also reuse an existing bucket and create a new folder inside it and pass the folder name in the s3 bucket key.

## Installation

  ```bash
  # Clone the repository 
  git clone https://github.com/dipayan/aws-eks-iaac.git
  # Change into the directory
  cd aws-eks-iaac
  cd terraform
  # Create a terraform.tfvars
  cp terraform.tfvars terraform.tfvars.sample
  # Initialize the script
  make init
  # Plan for the infrastructure setup
  make plan
  # Once validated and confirmed run the following to create the infra
  make apply

  ```

## Using the cluster

  **Once installation is finished you can run the following**
  ```bash
  kubectl get no
  kubectl get po
  ```

## Author

Dipayan Biswas