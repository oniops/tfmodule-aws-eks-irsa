################################################################################
# Amazon CloudWatch Observability Policy
################################################################################

resource "aws_iam_role_policy_attachment" "amazon_cloudwatch_observability" {
  for_each = {
    for k, v in {
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      AWSXrayWriteOnlyAccess      = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : k => v if var.create && var.attach_cloudwatch_observability_policy
  }

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
