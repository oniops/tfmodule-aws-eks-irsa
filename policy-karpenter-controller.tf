################################################################################
# Karpenter Controller Policy
################################################################################

# see - https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.1/getting-started/getting-started-with-karpenter/cloudformation.yaml

locals {

  create_karpenter_controller_policy = var.create && var.attach_karpenter_controller_policy
  karpenter_controller_policy_name   = "${local.iam_prefix}KarpenterControllerPolicy"
  karpenter_controller_node_role_arns = concat(var.karpenter_controller_node_role_arns, ["arn:aws:iam::${local.account_id}:role/${local.iam_prefix}KarpenterControllerNodeRole"])

  karpenter_controller_policy = templatefile("${path.module}/templates/policy-karpenter-controller.json.tpl", {
    region                              = local.region
    account_id                          = local.account_id
    cluster_name                        = local.cluster_name
    karpenter_controller_node_role_arns = join(", ", [for r in local.karpenter_controller_node_role_arns : "\"${r}\""])
  })

}

output "karpenter_controller_policy" {
  value = local.karpenter_controller_policy
}

resource "aws_iam_policy" "karpenterController" {
  count       = local.create_karpenter_controller_policy ? 1 : 0
  path        = var.role_path
  name        = local.karpenter_controller_policy_name
  description = "Provides permissions to handle node termination events via the Node Termination Handler"
  policy      = local.karpenter_controller_policy

  tags = merge(local.tags,
    var.additional_tags, {
      Name = local.karpenter_controller_policy_name
    })
}

resource "aws_iam_role_policy_attachment" "karpenterController" {
  count      = local.create_karpenter_controller_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.karpenterController[0].arn
}

################################################################################
# Pod Identity Association
################################################################################

locals {
  namespace_sa_pairs = local.create_karpenter_controller_policy  &&  local.create_pod_identity_association ? [
    for nsa in var.oidc_provider.namespace_service_accounts :
    {
      namespace       = split(":", nsa)[0]
      service_account = split(":", nsa)[1]
    }
  ] : []
}

resource "aws_eks_pod_identity_association" "karpenterPodIdentity" {
  for_each        = {for idx, pair in local.namespace_sa_pairs : idx => pair}
  role_arn        = aws_iam_role.this[0].arn
  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
}
