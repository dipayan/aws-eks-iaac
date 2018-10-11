variable "aws_region" {
  default     = "us-east-1"
  description = "Region"
}

variable "vpc_id" {
}

variable "eks_private_subnets" {
  type = "list"

  default = []
}

variable "cluster_name" {
  default = "mycluster"
}

variable "environment" {
  default = "dev"
}

variable "allowed_cidr_blocks" {
}

variable "allowed_external_cidr" {
}

variable "ami_id" {
  type = "map"

  default = {
    us-east-1 = "ami-dea4d5a1"
    us-west-2 = "ami-73a6e20b"
  }
}

variable "eks_worker_desired_capacity" {
  default = "3"
}

variable "eks_worker_max_size" {
  default = "4"
}

variable "eks_worker_min_size" {
  default = "3"
}

variable "instance_type" {
  default = "m5.large"
}

variable "key_name" {
  default = "mycluster-dev"
}

variable "ebs_optimized" {
  default = true
}

variable "ebs_volume_size" {
  default = "80"
}

variable "public_ip" {
  default = false
}

variable "elb_is_internal" {
  default = true
}

variable "ingress_http_port" {
  default = 30080
}

variable "ingress_https_port" {
  default = 30443
}

variable "ingress_domain_name" {
  default = "example.com"
}

variable "external_sg" {
}

variable "eks_ingress_controller_cert" {
}
