################################################################################
# AWS Gateway Controller Policy
################################################################################

data "aws_iam_policy_document" "aws_gateway_controller" {
  count = var.create && var.attach_aws_gateway_controller_policy ? 1 : 0

  # https://github.com/aws/aws-application-networking-k8s/blob/v0.0.11/examples/recommended-inline-policy.json
  statement {
    actions = [
      "vpc-lattice:*",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_gateway_controller" {
  count       = var.create && var.attach_aws_gateway_controller_policy ? 1 : 0
  name_prefix = "${var.policy_name_prefix}AWSGatewayController-"
  path        = var.role_path
  description = "Provides permissions for the AWS Gateway Controller"
  policy      = data.aws_iam_policy_document.aws_gateway_controller[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "aws_gateway_controller" {
  count      = var.create && var.attach_aws_gateway_controller_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.aws_gateway_controller[0].arn
}
