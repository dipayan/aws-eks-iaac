resource "aws_iam_role" "eks-cluster-iam-role" {
  name               = "${var.cluster_name}-${var.environment}-eks-cluster-iam-role"
  path               = "/"
  assume_role_policy = "${file("./artifacts/eks-cluster-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster-iam-role.name}"
}

resource "aws_iam_role" "eks-worker-iam-role" {
  name               = "${var.cluster_name}-${var.environment}-eks-worker-iam-role"
  path               = "/"
  assume_role_policy = "${file("./artifacts/eks-worker-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-worker-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-worker-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-worker-iam-role.name}"
}

resource "aws_iam_instance_profile" "eks-worker-iam-profile" {
  name = "${var.cluster_name}-${var.environment}-eks-worker-iam-profile"
  role = "${aws_iam_role.eks-worker-iam-role.name}"
}
