################################################################################
# Amazon Managed Service for Prometheus Policy
################################################################################

# https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html
data "aws_iam_policy_document" "amazon_managed_service_prometheus" {
  count = var.create && var.attach_amazon_managed_service_prometheus_policy ? 1 : 0

  statement {
    actions = [
      "aps:RemoteWrite",
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]

    resources = var.amazon_managed_service_prometheus_workspace_arns
  }
}

resource "aws_iam_policy" "amazon_managed_service_prometheus" {
  count = var.create && var.attach_amazon_managed_service_prometheus_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}Managed_Service_Prometheus_Policy-"
  path        = var.role_path
  description = "Provides permissions to for Amazon Managed Service for Prometheus"
  policy      = data.aws_iam_policy_document.amazon_managed_service_prometheus[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "amazon_managed_service_prometheus" {
  count = var.create && var.attach_amazon_managed_service_prometheus_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.amazon_managed_service_prometheus[0].arn
}
