{
    "Version": "2012-10-17",
    "Statement": [
%{ if vpc_cni_enable_ipv4 == true }
        {
            "Sid": "AmazonEKSCNIPolicyIPV4",
            "Effect": "Allow",
            "Action": [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeSubnets",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },%{ endif }
%{ if vpc_cni_enable_ipv6 == true }
        {
            "Sid": "AmazonEKSCNIPolicyIPV6",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:AssignIpv6Addresses"
            ],
            "Resource": "*"
        },%{ endif }
%{ if vpc_cni_enable_cloudwatch_logs == true }
        {
            "Sid": "CloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },%{ endif }
        {
            "Sid": "AmazonEKSCNIPolicyENITag",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*"
            ]
        }
    ]
}
