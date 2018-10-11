resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.cluster_name}-${var.environment}"
  role_arn = "${aws_iam_role.eks-cluster-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster-sg.id}"]

    subnet_ids = "${var.eks_private_subnets}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]
}
