locals {
  eks-worker-userdata = <<USERDATA
#!/bin/bash -xe
CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.eks-cluster.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster_name}-${var.environment},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${var.aws_region},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,30,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.eks-cluster.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet kube-proxy
USERDATA
}

resource "aws_launch_configuration" "eks-worker-launch-config" {
  associate_public_ip_address = "${var.public_ip}"
  iam_instance_profile        = "${aws_iam_instance_profile.eks-worker-iam-profile.name}"
  image_id                    = "${var.ami_id[var.aws_region]}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.cluster_name}-${var.environment}-eks-launch-config"
  security_groups             = ["${aws_security_group.eks-worker-sg.id}"]
  user_data_base64            = "${base64encode(local.eks-worker-userdata)}"
  ebs_optimized               = "${var.ebs_optimized}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.ebs_volume_size}"
  }
}

resource "aws_autoscaling_group" "eks-worker-autoscaling-group" {
  desired_capacity     = "${var.eks_worker_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.eks-worker-launch-config.id}"
  max_size             = "${var.eks_worker_max_size}"
  min_size             = "${var.eks_worker_min_size}"
  name                 = "${var.cluster_name}-${var.environment}-eks-worker-asg"

  vpc_zone_identifier = "${var.eks_private_subnets}"

  tags = ["${
    list(
      map("key", "Environment", "value", "${var.environment}", "propagate_at_launch", true),
      map("key", "Terraform", "value", "true", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${var.cluster_name}-${var.environment}", "value", "owned", "propagate_at_launch", true),
      map("key", "Name", "value", "${var.cluster_name}-${var.environment}-eks-worker-asg", "propagate_at_launch", true)
    )
    }"]
}
