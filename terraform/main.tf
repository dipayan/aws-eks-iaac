# Terraform version
terraform {
  required_version = ">= 0.11.0"

 backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

data "template_file" "eks-setup-cluster-postscript" {
  template = "${file("artifacts/eks-setup-cluster-postscript.sh")}"

  vars {
    aws_ingress_alb_arn       = "${aws_alb.eks-ingress-controller-lb.arn}"
    aws_autoscaling_group_arn = "${aws_autoscaling_group.eks-worker-autoscaling-group.arn}"
    ingress_http_port         = "${var.ingress_http_port}"
    ingress_https_port        = "${var.ingress_https_port}"
    ingress_domain_name       = "${var.ingress_domain_name}"
    eks_cluster_endpoint      = "${aws_eks_cluster.eks-cluster.endpoint}"
    eks_cluster_name          = "${var.cluster_name}-${var.environment}"
    eks_cluster_cert          = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
    eks_iam_worker_arn        = "${aws_iam_role.eks-worker-iam-role.arn}"
  }
}

resource "null_resource" "eks-cluster-setup-initiated" {
  triggers {
    template = "${data.template_file.eks-setup-cluster-postscript.rendered}"
  }

  provisioner "local-exec" {
    command = <<EOT
    sleep 300
    mkdir -p /data/kubernetes/${var.cluster_name}-${var.environment}
    echo "\${data.template_file.eks-setup-cluster-postscript.rendered}"\ > /data/kubernetes/${var.cluster_name}-${var.environment}/eks-setup-cluster-postscript.sh
    cd /data/kubernetes/${var.cluster_name}-${var.environment}
    /bin/sh -x /data/kubernetes/${var.cluster_name}-${var.environment}/eks-setup-cluster-postscript.sh
EOT
  }
}
