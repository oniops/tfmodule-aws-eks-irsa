{
    "Version": "2012-10-17",
    "Statement": [
%{ if allow_self_assume_role == true }
        {
            "Sid": "ExplicitSelfRoleAssumption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "ArnLike": {
                    "aws:PrincipalArn": "${principal_role_arn}"
                }
            }
        },%{ endif }
%{ if enable_pod_identity_association == true }
        {
            "Sid": "ExplicitPodIdentityRoleAssumption",
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:TagSession",
                "sts:AssumeRole"
            ]
        },%{ endif }
%{ if enable_irsa_oidc_association == true }
        {
            "Sid": "WithWebIdentityRoleAssumption",
            "Effect": "Allow",
            "Principal": {
                "Federated": "${provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "${assume_role_condition_test}": {
                    "${replace(provider_arn, "/^(.*provider/)/", "")}:aud": "sts.amazonaws.com",
                    "${replace(provider_arn, "/^(.*provider/)/", "")}:sub": [
                      %{ for idx, sa in namespace_service_accounts ~}
                      "system:serviceaccount:${sa}"%{ if idx < length(namespace_service_accounts) - 1 },%{ endif }
                      %{ endfor ~}
                    ]
                }
            }
        }%{ endif }
    ]
}