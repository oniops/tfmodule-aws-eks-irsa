locals {
  account_id                      = var.eks_context.account_id
  region                          = var.eks_context.region
  dns_suffix                      = data.aws_partition.current.dns_suffix
  project                         = var.eks_context.project
  tags                            = var.eks_context.tags
  name_prefix                     = var.eks_context.name_prefix
  cluster_name                    = var.eks_context.cluster_name
  cluster_simple_name             = var.eks_context.cluster_simple_name
  iam_prefix                      = "${local.project}${title(local.cluster_simple_name)}"
  role_name                       = "${local.iam_prefix}${title(var.name)}Role"
  enable_pod_identity_association = var.create && var.enable_pod_identity_association
  enable_irsa_oidc_association    = var.create && length(var.oidc_provider) > 0

  irsa_trusted_role = templatefile("${path.module}/templates/irsa-role-trusted-v1.0.tpl", {
    allow_self_assume_role          = var.allow_self_assume_role
    enable_irsa_oidc_association    = local.enable_irsa_oidc_association
    enable_pod_identity_association = local.enable_pod_identity_association
    principal_role_arn              = "arn:aws:iam::${local.account_id}:role${var.role_path}${local.role_name}"
    provider_arn                    = var.oidc_provider.provider_arn
    namespace_service_accounts      = var.oidc_provider.namespace_service_accounts
    assume_role_condition_test      = var.assume_role_condition_test
  })

}

resource "aws_iam_role" "this" {
  count                 = var.create ? 1 : 0
  name                  = local.role_name
  path                  = var.role_path
  description           = var.role_description
  assume_role_policy    = local.irsa_trusted_role
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.role_permissions_boundary_arn
  force_detach_policies = var.force_detach_policies
  tags                  = local.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = {for k, v in var.role_policy_arns : k => v if var.create}
  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
