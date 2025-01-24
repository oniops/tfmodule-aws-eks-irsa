################################################################################
# Mountpoint S3 CSI Driver Policy
################################################################################

#https://github.com/awslabs/mountpoint-s3/blob/main/doc/CONFIGURATION.md#iam-permissions
data "aws_iam_policy_document" "mountpoint_s3_csi" {
  count = var.create && var.attach_mountpoint_s3_csi_policy ? 1 : 0

  statement {
    sid = "MountpointFullBucketAccess"
    actions = ["s3:ListBucket"]
    resources = coalescelist(var.mountpoint_s3_csi_bucket_arns, ["arn:aws:s3:::*"])
  }

  statement {
    sid = "MountpointFullObjectAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject"
    ]
    resources = var.mountpoint_s3_csi_path_arns
  }

  dynamic "statement" {
    for_each = length(var.mountpoint_s3_csi_kms_arns) > 0 ? [1] : []
    content {
      actions = [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ]

      resources = var.mountpoint_s3_csi_kms_arns
    }
  }
}

resource "aws_iam_policy" "mountpoint_s3_csi" {
  count = var.create && var.attach_mountpoint_s3_csi_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}Mountpoint_S3_CSI-"
  path        = var.role_path
  description = "Mountpoint S3 CSI driver policy to allow management of S3"
  policy      = data.aws_iam_policy_document.mountpoint_s3_csi[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "mountpoint_s3_csi" {
  count = var.create && var.attach_mountpoint_s3_csi_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.mountpoint_s3_csi[0].arn
}
