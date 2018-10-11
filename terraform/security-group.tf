resource "aws_security_group" "eks-cluster-sg" {
  name        = "${var.cluster_name}-${var.environment}-eks-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.cluster_name}-${var.environment}-eks-cluster-sg",
     "Environment", "${var.environment}",
     "kubernetes.io/cluster/${var.cluster_name}-${var.environment}", "owned"
    )
  }"
}

resource "aws_security_group_rule" "eks-api-node-ingress-sg-rule" {
  description              = "EKS Cluster API Server to EKS worker"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster-sg.id}"
  source_security_group_id = "${aws_security_group.eks-worker-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-api-external-ingress-sg-rule" {
  cidr_blocks       = ["${var.allowed_external_cidr}"]
  description       = "Allow External Access"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster-sg.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-api-jumpbox-ingress-sg-rule" {
  description              = "Allow External Access from Jumpbox"
  security_group_id        = "${aws_security_group.eks-cluster-sg.id}"
  source_security_group_id = "${var.external_sg}"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "eks-worker-sg" {
  name        = "${var.cluster_name}-${var.environment}-eks-worker-sg"
  description = "Security group for all worker in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.cluster_name}-${var.environment}-eks-worker-sg",
     "Environment", "${var.environment}",
     "kubernetes.io/cluster/${var.cluster_name}-${var.environment}", "owned"
    )
  }"
}

resource "aws_security_group_rule" "eks-worker-ingress-self-rule" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-worker-sg.id}"
  source_security_group_id = "${aws_security_group.eks-worker-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-cluster-rule" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-worker-sg.id}"
  source_security_group_id = "${aws_security_group.eks-cluster-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-external-rule" {
  description       = "Allow external traffic to the  worker"
  cidr_blocks       = ["${var.allowed_cidr_blocks}"]
  from_port         = 0
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-worker-sg.id}"
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-jumpbox-rule" {
  description              = "Allow Jumpbox traffic to the worker "
  security_group_id        = "${aws_security_group.eks-worker-sg.id}"
  source_security_group_id = "${var.external_sg}"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "eks-ingress-controller-lb-sg" {
  name        = "${var.cluster_name}-${var.environment}-eks-ingress-lb-sg"
  description = "${var.cluster_name}-${var.environment}-eks-ingress-lb-sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
    self        = false
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
    self        = false
  }

  ingress {
    security_groups = ["${var.external_sg}"]
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    self            = false
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.cluster_name}-${var.environment}-eks-ingress-lb-sg",
     "Environment", "${var.environment}",
     "kubernetes.io/cluster/${var.cluster_name}-${var.environment}", "owned"
    )
  }"

  lifecycle {
    create_before_destroy = true
  }
}
