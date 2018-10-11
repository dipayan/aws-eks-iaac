resource "aws_alb" "eks-ingress-controller-lb" {
  enable_deletion_protection = false
  name                       = "${var.cluster_name}-${var.environment}-eks-ingress-lb"
  internal                   = "${var.elb_is_internal}"

  idle_timeout    = 900
  security_groups = ["${aws_security_group.eks-ingress-controller-lb-sg.id}"]
  subnets         = "${var.eks_private_subnets}"

  lifecycle {
    create_before_destroy = true
  }
}

#  resource "aws_alb_listener" "eks-ingress-controller-lb-listener-http" {
#  load_balancer_arn = "${aws_alb.eks-ingress-controller-lb.arn}"
#  port              = "80"
#  protocol          = "HTTP"
#
#  default_action {
#    target_group_arn = "${aws_alb_target_group.eks-ingress-controller-tg-http.arn}"
#    type             = "forward"
#  }
#}

resource "aws_alb_target_group" "eks-ingress-controller-tg-http" {
  name     = "${var.cluster_name}-${var.environment}-eks-ingress-tg-http"
  port     = "${var.ingress_http_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 20
    path                = "/"
    interval            = 30
    matcher             = "200,404"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "eks-ingress-controller-tg-attachment-http" {
  alb_target_group_arn   = "${aws_alb_target_group.eks-ingress-controller-tg-http.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.eks-worker-autoscaling-group.id}"
}

 resource "aws_alb_listener" "eks-ingress-controller-lb-listener-https" {
   load_balancer_arn = "${aws_alb.eks-ingress-controller-lb.arn}"
   port              = "443"
   protocol          = "HTTPS"

   ssl_policy        = "ELBSecurityPolicy-2015-05"
   certificate_arn   = "${var.eks_ingress_controller_cert}"

   default_action {
     target_group_arn = "${aws_alb_target_group.eks-ingress-controller-tg-http.arn}"
     type             = "forward"
   }
 }

# resource "aws_alb_target_group" "eks-ingress-controller-tg-https" {
#   name     = "${var.cluster_name}-${var.environment}-eks-ingress-tg-https"
#   port     = "${var.ingress_https_port}"
#   protocol = "HTTP"
#   vpc_id   = "${var.vpc_id}"
#
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 5
#     path                = "/"
#     interval            = 10
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# resource "aws_autoscaling_attachment" "eks-ingress-controller-tg-attachment-https" {
#   alb_target_group_arn   = "${aws_alb_target_group.eks-ingress-controller-tg-https.arn}"
#   autoscaling_group_name = "${aws_autoscaling_group.eks-worker-autoscaling-group.id}"
# }

