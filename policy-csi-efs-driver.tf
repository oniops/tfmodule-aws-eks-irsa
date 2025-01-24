################################################################################
# EFS CSI Driver Policy
################################################################################

# https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-example.json
data "aws_iam_policy_document" "efs_csi" {
  count = var.create && var.attach_efs_csi_policy ? 1 : 0

  statement {
    actions = [
      "ec2:DescribeAvailabilityZones",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
    ]

    resources = ["*"]
  }

  statement {
    actions = ["elasticfilesystem:CreateAccessPoint"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values = ["true"]
    }
  }

  statement {
    actions = ["elasticfilesystem:TagResource"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values = ["true"]
    }
  }

  statement {
    actions = ["elasticfilesystem:DeleteAccessPoint"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values = ["true"]
    }
  }
}

resource "aws_iam_policy" "efs_csi" {
  count = var.create && var.attach_efs_csi_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}EFS_CSI_Policy-"
  path        = var.role_path
  description = "Provides permissions to manage EFS volumes via the container storage interface driver"
  policy      = data.aws_iam_policy_document.efs_csi[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "efs_csi" {
  count = var.create && var.attach_efs_csi_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.efs_csi[0].arn
}