{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid" : "AllowScopedEC2InstanceAccessActions",
      "Effect" : "Allow",
      "Action" : [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource" : [
        "arn:aws:ec2:${region}::image/*",
        "arn:aws:ec2:${region}::snapshot/*",
        "arn:aws:ec2:*:${account_id}:security-group/*",
        "arn:aws:ec2:*:${account_id}:subnet/*"
      ]
    },
    {
      "Sid" : "AllowScopedEC2LaunchTemplateAccessActions",
      "Effect" : "Allow",
      "Resource" : "arn:aws:ec2:*:${account_id}:launch-template/*",
      "Action" : [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Condition" : {
        "StringEquals" : {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}" : "owned"
        },
        "StringLike" : {
          "aws:ResourceTag/karpenter.sh/nodepool" : "*"
        }
      }
    },
    {
      "Sid" : "AllowScopedEC2InstanceActionsWithTags",
      "Effect" : "Allow",
      "Action" : [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Resource" : [
        "arn:aws:ec2:*:${account_id}:fleet/*",
        "arn:aws:ec2:*:${account_id}:instance/*",
        "arn:aws:ec2:*:${account_id}:volume/*",
        "arn:aws:ec2:*:${account_id}:network-interface/*",
        "arn:aws:ec2:*:${account_id}:launch-template/*",
        "arn:aws:ec2:*:${account_id}:spot-instances-request/*"
      ],
      "Condition" : {
        "StringEquals" : {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:RequestTag/eks:eks-cluster-name" : "${cluster_name}"
        },
        "StringLike" : {
          "aws:RequestTag/karpenter.sh/nodepool" : "*"
        }
      }
    },
    {
      "Sid" : "AllowScopedResourceCreationTagging",
      "Effect" : "Allow",
      "Action" : "ec2:CreateTags",
      "Resource" : [
        "arn:aws:ec2:*:${account_id}:fleet/*",
        "arn:aws:ec2:*:${account_id}:instance/*",
        "arn:aws:ec2:*:${account_id}:volume/*",
        "arn:aws:ec2:*:${account_id}:network-interface/*",
        "arn:aws:ec2:*:${account_id}:launch-template/*",
        "arn:aws:ec2:*:${account_id}:spot-instances-request/*"
      ],
      "Condition" : {
        "StringEquals" : {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:RequestTag/eks:eks-cluster-name" : "${cluster_name}",
          "ec2:CreateAction" : [
            "RunInstances",
            "CreateFleet",
            "CreateLaunchTemplate"
          ]
        },
        "StringLike" : {
          "aws:RequestTag/karpenter.sh/nodepool" : "*"
        }
      }
    },
    {
      "Sid" : "AllowScopedResourceTagging",
      "Effect" : "Allow",
      "Action" : "ec2:CreateTags",
      "Resource" : "arn:aws:ec2:*:${account_id}:instance/*",
      "Condition" : {
        "StringEquals" : {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}" : "owned"
        },
        "StringLike" : {
          "aws:ResourceTag/karpenter.sh/nodepool" : "*"
        },
        "StringEqualsIfExists" : {
          "aws:RequestTag/eks:eks-cluster-name" : "${cluster_name}"
        },
        "ForAllValues:StringEquals" : {
          "aws:TagKeys" : [
            "eks:eks-cluster-name",
            "karpenter.sh/nodeclaim",
            "Name"
          ]
        }
      }
    },
    {
      "Sid" : "AllowScopedDeletion",
      "Effect" : "Allow",
      "Action" : [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Resource" : [
        "arn:aws:ec2:*:${account_id}:instance/*",
        "arn:aws:ec2:*:${account_id}:launch-template/*"
      ],
      "Condition" : {
        "StringEquals" : {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}" : "owned"
        },
        "StringLike" : {
          "aws:ResourceTag/karpenter.sh/nodepool" : "*"
        }
      }
    },
    {
      "Sid" : "AllowRegionalReadActions",
      "Effect" : "Allow",
      "Action" : [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets"
      ],
      "Resource" : "*",
      "Condition" : {
        "StringEquals" : {
          "aws:RequestedRegion" : "${region}"
        }
      }
    },
    {
      "Sid" : "AllowSSMReadActions",
      "Effect" : "Allow",
      "Action" : "ssm:GetParameter",
      "Resource" : "arn:aws:ssm:*:*:parameter/aws/service/*"
    },
    {
      "Sid" : "AllowPricingReadActions",
      "Effect" : "Allow",
      "Action" : "pricing:GetProducts",
      "Resource" : "*"
    },
    {
      "Sid" : "AllowInterruptionQueueActions",
      "Effect" : "Allow",
      "Action" : [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ],
      "Resource" : "arn:aws:sqs:${region}:${account_id}:${cluster_name}"
    },
    {
      "Sid" : "AllowPassingInstanceRole",
      "Effect" : "Allow",
      "Action" : "iam:PassRole",
      "Resource" : [ ${karpenter_controller_node_role_arns} ],
      "Condition" : {
        "StringEquals" : {
          "iam:PassedToService" : [
            "ec2.amazonaws.com",
            "ec2.amazonaws.com.cn"
          ]
        }
      }
    },
    {
      "Sid" : "AllowScopedInstanceProfileCreationActions",
      "Effect" : "Allow",
      "Action" : [
        "iam:CreateInstanceProfile"
      ],
      "Resource" : "arn:aws:iam::${account_id}:instance-profile/*",
      "Condition" : {
        "StringEquals" : {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:RequestTag/eks:eks-cluster-name" : "${cluster_name}",
          "aws:RequestTag/topology.kubernetes.io/region" : "${region}"
        },
        "StringLike" : {
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
        }
      }
    },
    {
      "Sid" : "AllowScopedInstanceProfileTagActions",
      "Effect" : "Allow",
      "Action" : [
        "iam:TagInstanceProfile"
      ],
      "Resource" : "arn:aws:iam::${account_id}:instance-profile/*",
      "Condition" : {
        "StringEquals" : {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:ResourceTag/topology.kubernetes.io/region" : "${region}",
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:RequestTag/eks:eks-cluster-name" : "${cluster_name}",
          "aws:RequestTag/topology.kubernetes.io/region" : "${region}"
        },
        "StringLike" : {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*",
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
        }
      }
    },
    {
      "Sid" : "AllowScopedInstanceProfileActions",
      "Effect" : "Allow",
      "Action" : [
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:DeleteInstanceProfile"
      ],
      "Resource" : "arn:aws:iam::${account_id}:instance-profile/*",
      "Condition" : {
        "StringEquals" : {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}" : "owned",
          "aws:ResourceTag/topology.kubernetes.io/region" : "${region}"
        },
        "StringLike" : {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*"
        }
      }
    },
    {
      "Sid" : "AllowInstanceProfileReadActions",
      "Effect" : "Allow",
      "Action" : "iam:GetInstanceProfile",
      "Resource" : "arn:aws:iam::${account_id}:instance-profile/*"
    },
    {
      "Sid" : "AllowAPIServerEndpointDiscovery",
      "Effect" : "Allow",
      "Action" : "eks:DescribeCluster",
      "Resource" : "arn:aws:eks:${region}:${account_id}:cluster/${cluster_name}"
    }
  ]
}