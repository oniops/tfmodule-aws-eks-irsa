################################################################################
# Mountpoint S3 CSI Driver Policy
# see - https://github.com/awslabs/mountpoint-s3/blob/main/doc/CONFIGURATION.md#iam-permissions
################################################################################

locals {
  aws_s3mount_csi_policy_name = "${local.iam_prefix}${title(var.name)}Policy"
  aws_s3mount_csi_policy = templatefile("${path.module}/templates/aws-s3mount-csi-policy-v1.0.tpl", {
    mountpoint_s3_csi_arns = coalescelist(var.mountpoint_s3_csi_bucket_arns, ["arn:aws:s3:::*"])
    mountpoint_s3_csi_path_arns = var.mountpoint_s3_csi_path_arns
    mountpoint_s3_csi_kms_arns  = var.mountpoint_s3_csi_kms_arns
  })
}

resource "aws_iam_policy" "s3Csi" {
  count       = var.create && var.attach_mountpoint_s3_csi_policy ? 1 : 0
  name        = local.aws_s3mount_csi_policy_name
  description = "Mountpoint S3 CSI driver policy to allow management of S3"
  policy      = local.aws_s3mount_csi_policy
  path        = var.role_path
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "s3Csi" {
  count      = var.create && var.attach_mountpoint_s3_csi_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.s3Csi[0].arn
}
