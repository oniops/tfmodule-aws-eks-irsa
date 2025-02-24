################################################################################
# EBS CSI Driver Policy
# see - arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
#       https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/example-iam-policy.json
################################################################################

locals {
  aws_ebs_csi_policy_name = "${local.iam_prefix}${title(var.name)}Policy"
  aws_ebs_csi_policy = templatefile("${path.module}/templates/aws-ebs-csi-policy-v1.0.tpl", {
    ebs_csi_kms_ids = var.ebs_csi_kms_ids
  })
}

resource "aws_iam_policy" "ebsCsi" {
  count       = var.create && var.attach_ebs_csi_policy ? 1 : 0
  name        = local.aws_ebs_csi_policy_name
  description = "Provides permissions to manage EBS volumes via the container storage interface driver"
  policy      = local.aws_ebs_csi_policy
  path        = var.role_path
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "ebsCsi" {
  count      = var.create && var.attach_ebs_csi_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.ebsCsi[0].arn
}
