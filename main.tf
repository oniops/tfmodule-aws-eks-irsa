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
  create_pod_identity_association = var.create && length(var.oidc_provider) > 0
}

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  dynamic "statement" {
    # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
    for_each = var.allow_self_assume_role ? [1] : []

    content {
      sid    = "ExplicitSelfRoleAssumption"
      effect = "Allow"
      principals {
        type = "AWS"
        identifiers = ["*"]
      }
      actions = ["sts:AssumeRole"]
      condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values = ["arn:aws:iam::${local.account_id}:role${var.role_path}${local.role_name}"]
      }
    }
  }

  dynamic "statement" {
    # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
    for_each = local.create_pod_identity_association ? [1] : []
    content {
      sid    = "ExplicitPodIdentityRoleAssumption"
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }
      actions = [
        "sts:TagSession",
        "sts:AssumeRole"
      ]
    }
  }

  dynamic "statement" {
    for_each = local.create_pod_identity_association ? [1] : []

    content {
      effect = "Allow"
      principals {
        type = "Federated"
        identifiers = [var.oidc_provider.provider_arn]
      }

      actions = ["sts:AssumeRoleWithWebIdentity"]

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(var.oidc_provider.provider_arn, "/^(.*provider/)/", "")}:sub"
        values   = [for sa in var.oidc_provider.namespace_service_accounts : "system:serviceaccount:${sa}"]
      }

      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(var.oidc_provider.provider_arn, "/^(.*provider/)/", "")}:aud"
        values = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count                 = var.create ? 1 : 0
  name                  = local.role_name
  path                  = var.role_path
  description           = var.role_description
  assume_role_policy    = data.aws_iam_policy_document.this[0].json
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
