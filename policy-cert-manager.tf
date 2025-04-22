################################################################################
# Cert Manager Policy
################################################################################

# see - https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-role
locals {
  cert_manager_policy_name = "${local.iam_prefix}${title(var.name)}Policy"
  cert_manager_policy = templatefile("${path.module}/templates/policy-cert-manager-v1.0.tpl", {
  })
}

resource "aws_iam_policy" "certManager" {
  count       = var.create && var.attach_cert_manager_policy ? 1 : 0
  name        = local.cert_manager_policy_name
  path        = var.role_path
  description = "Cert Manager policy to allow management of Route53 hosted zone records"
  policy      = local.cert_manager_policy
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  count      = var.create && var.attach_cert_manager_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.certManager[0].arn
}
