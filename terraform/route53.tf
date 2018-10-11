# resource "aws_route53_zone" "eks_ingress_route53" {
#   name       = "${var.ingress_domain_name}"
#   vpc_id     = "${var.vpc_id}"
#   vpc_region = "${var.aws_region}"
# }
# resource "aws_route53_record" "eks_nginx_ingress_record" {
#   zone_id = "${aws_route53_zone.eks_ingress_route53.zone_id}"
#   name    = "*.${var.ingress_domain_name}"
#   type    = "CNAME"
#   ttl     = "300"
#   records = ["${aws_alb.eks-ingress-controller-lb.dns_name}"]
# }

