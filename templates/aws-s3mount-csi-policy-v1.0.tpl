{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "MountpointListBucketAccess",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": ${jsonencode(mountpoint_s3_csi_arns)}
        },
        {
            "Sid": "MountpointFullObjectAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:AbortMultipartUpload"
            ],
            "Resource": ${jsonencode(mountpoint_s3_csi_path_arns)}
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": ${jsonencode(mountpoint_s3_csi_kms_arns)}
        }
    ]
}