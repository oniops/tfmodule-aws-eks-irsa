################################################################################
# VPC CNI Policy
# see ipv4 - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
#     ipv6 - https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
#     cloudwatch - https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html#cni-network-policy-setup
################################################################################

locals {
  aws_vpc_cni_policy_name = "${local.iam_prefix}${title(var.name)}Policy"
  aws_vpc_cni_policy = templatefile("${path.module}/templates/aws-vpc-cni-policy-v1.0.tpl", {
    vpc_cni_enable_ipv4            = var.vpc_cni_enable_ipv4
    vpc_cni_enable_ipv6            = var.vpc_cni_enable_ipv6
    vpc_cni_enable_cloudwatch_logs = var.vpc_cni_enable_cloudwatch_logs
  })
}

resource "aws_iam_policy" "vpcCni" {
  count       = var.create && var.attach_vpc_cni_policy ? 1 : 0
  name        = local.aws_vpc_cni_policy_name
  description = "Provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IPv4/IPv6 address configuration on your EKS worker nodes"
  policy      = local.aws_vpc_cni_policy
  path        = var.role_path
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "vpcCni" {
  count      = var.create && var.attach_vpc_cni_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.vpcCni[0].arn
}
