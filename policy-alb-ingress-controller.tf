################################################################################
# AWS Load Balancer Controller Policy
################################################################################

# https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json
locals {
  alb_ingress_controller_policy_name = "${local.iam_prefix}${title(var.name)}Policy"
  alb_ingress_controller_policy = templatefile("${path.module}/templates/policy-alb-ingress-controller-v2.12.tpl", {
  })
  attach_load_balancer_controller_targetgroup_binding_only_policy = false
}

resource "aws_iam_policy" "load_balancer_controller" {
  count       = var.create && var.attach_load_balancer_controller_policy ? 1 : 0
  name_prefix = local.alb_ingress_controller_policy_name
  path        = var.role_path
  description = "Provides permissions for AWS Load Balancer Controller addon"
  policy      = local.alb_ingress_controller_policy

  tags = merge(local.tags, {
    Name = local.alb_ingress_controller_policy_name
  })
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  count = var.create && var.attach_load_balancer_controller_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.load_balancer_controller[0].arn
}

################################################################################
# AWS Load Balancer Controller TargetGroup Binding Only Policy
################################################################################

# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/targetgroupbinding/targetgroupbinding/#reference
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#setup-iam-manually
data "aws_iam_policy_document" "load_balancer_controller_targetgroup_only" {
  count = var.create && local.attach_load_balancer_controller_targetgroup_binding_only_policy ? 1 : 0

  statement {
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeVpcs",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]

    resources = var.load_balancer_controller_targetgroup_arns
  }
}

resource "aws_iam_policy" "load_balancer_controller_targetgroup_only" {
  count = var.create && local.attach_load_balancer_controller_targetgroup_binding_only_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}AWS_Load_Balancer_Controller_TargetGroup_Only-"
  path        = var.role_path
  description = "Provides permissions for AWS Load Balancer Controller addon in TargetGroup binding only scenario"
  policy      = data.aws_iam_policy_document.load_balancer_controller_targetgroup_only[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_targetgroup_only" {
  count = var.create && local.attach_load_balancer_controller_targetgroup_binding_only_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.load_balancer_controller_targetgroup_only[0].arn
}
