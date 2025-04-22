variable "create" {
  description = "Whether to create a role"
  type        = bool
  default     = true
}

variable "name" {
  description = "IAM role name for IRSA"
  type        = string
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "policy_name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = "AmazonEKS_"
}

variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type = map(string)
  default = {}
}

variable "oidc_provider" {
  type        = any
  description = <<-EOF
Map of OIDC providers where each provider map should contain the `provider_arn` and `namespace_service_accounts`

  Exam 1)
    oidc_provider = {
      provider_arn               = "arn:aws:iam::111122223333:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
      namespace_service_accounts = [ "certmanager:certmanager" ]
    }

  Exam 2)
    oidc_provider = {
      provider_arn               = module.ctx.eks_oidc_provider_arn
      namespace_service_accounts = [ "kube-system:aws-node" ]
    }

EOF
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

variable "enable_pod_identity_association" {
  type        = bool
  default     = false
  description = <<-EOF
Determines whether to allow the role to be [pod-identity-association](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/pod-identities.html)
see - [EKS Pod Identity restrictions](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html#pod-id-restrictions)

EOF
}

variable "allow_self_assume_role" {
  type        = bool
  default     = false
  description = <<-EOF
Determines whether to allow the role to be [assume itself](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_credentials_temp_control-access_monitor.html#id_credentials_temp_control-access_monitor-assume-role-web-id)
Strongly recommend `false` for Security, Only quickly test about pod feature.
EOF
}

################################################################################
# Policies
################################################################################

# AWS Gateway Controller
variable "attach_aws_gateway_controller_policy" {
  description = "Determines whether to attach the AWS Gateway Controller IAM policy to the role"
  type        = bool
  default     = false
}

# Cert Manager
variable "attach_cert_manager_policy" {
  description = "Determines whether to attach the Cert Manager IAM policy to the role"
  type        = bool
  default     = false
}

variable "cert_manager_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs to allow Cert manager to manage records"
  type = list(string)
  default = ["arn:aws:route53:::hostedzone/*"]
}

# Cluster autoscaler
variable "attach_cluster_autoscaler_policy" {
  description = "Determines whether to attach the Cluster Autoscaler IAM policy to the role"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_cluster_ids" {
  description = "[Deprecated - use `cluster_autoscaler_cluster_names`] List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy"
  type = list(string)
  default = []
}

variable "cluster_autoscaler_cluster_names" {
  description = "List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy"
  type = list(string)
  default = []
}

# EBS CSI
variable "attach_ebs_csi_policy" {
  description = "Determines whether to attach the EBS CSI IAM policy to the role"
  type        = bool
  default     = false
}

variable "ebs_csi_kms_ids" {
  type = list(string)
  default = []
  description = <<-EOF
KMS(CMK) IDs to allow EBS CSI to manage encrypted volumes.

  data "aws_kms_alias" "this" {  name = "alias/your-cmk-alias-name"  }
  ebs_csi_kms_ids = [data.aws_kms_alias.this.target_key_arn]
EOF
}

# EFS CSI
variable "attach_efs_csi_policy" {
  description = "Determines whether to attach the EFS CSI IAM policy to the role"
  type        = bool
  default     = false
}

# S3 CSI
variable "attach_mountpoint_s3_csi_policy" {
  description = "Determines whether to attach the Mountpoint S3 CSI IAM policy to the role"
  type        = bool
  default     = false
}

variable "mountpoint_s3_csi_bucket_arns" {
  type = list(string)
  default = []
  description = <<-EOF
S3 bucket ARNs to allow Mountpoint S3 CSI to list buckets.

Usage)
  attach_mountpoint_s3_csi_policy = true
  mountpoint_s3_csi_bucket_arns = [
    "arn:aws:s3:::your-s3-apple-bucket", "arn:aws:s3:::your-s3-banana-bucket"
  ]
  mountpoint_s3_csi_path_arns = [
    "arn:aws:s3:::your-s3-apple-bucket/*", "arn:aws:s3:::your-s3-banana-bucket/s3mount/*"
  ]
EOF

}

variable "mountpoint_s3_csi_path_arns" {
  type = list(string)
  default = []
  description = <<-EOF
S3 path ARNs to allow Mountpoint S3 CSI driver to manage items at the provided path(s).

Usage)
  attach_mountpoint_s3_csi_policy = true
  mountpoint_s3_csi_bucket_arns = [
    "arn:aws:s3:::your-s3-apple-bucket", "arn:aws:s3:::your-s3-banana-bucket"
  ]
  mountpoint_s3_csi_path_arns = [
    "arn:aws:s3:::your-s3-apple-bucket/*", "arn:aws:s3:::your-s3-banana-bucket/s3mount/*"
  ]
EOF

}

variable "mountpoint_s3_csi_kms_arns" {
  description = "KMS Key ARNs to allow Mountpoint S3 CSI driver to download and upload Objects of a S3 bucket using `aws:kms` SSE"
  type = list(string)
  default = []
}

# External DNS
variable "attach_external_dns_policy" {
  description = "Determines whether to attach the External DNS IAM policy to the role"
  type        = bool
  default     = false
}

variable "external_dns_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs to allow External DNS to manage records"
  type = list(string)
  default = ["arn:aws:route53:::hostedzone/*"]
}

# External Secrets
variable "attach_external_secrets_policy" {
  description = "Determines whether to attach the External Secrets policy to the role"
  type        = bool
  default     = false
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type = list(string)
  default = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type = list(string)
  default = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type = list(string)
  default = ["arn:aws:kms:*:*:key/*"]
}

variable "external_secrets_secrets_manager_create_permission" {
  description = "Determins whether External Secrets may use secretsmanager:CreateSecret"
  type        = bool
  default     = false
}

# FSx Lustre CSI
variable "attach_fsx_lustre_csi_policy" {
  description = "Determines whether to attach the FSx for Lustre CSI Driver IAM policy to the role"
  type        = bool
  default     = false
}

variable "fsx_lustre_csi_service_role_arns" {
  description = "Service role ARNs to allow FSx for Lustre CSI create and manage FSX for Lustre service linked roles"
  type = list(string)
  default = ["arn:aws:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"]
}

# AWS Load Balancer Controller
variable "attach_load_balancer_controller_policy" {
  description = "Determines whether to attach the Load Balancer Controller policy to the role"
  type        = bool
  default     = false
}

# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/targetgroupbinding/targetgroupbinding/#reference
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#setup-iam-manually
variable "attach_load_balancer_controller_targetgroup_binding_only_policy" {
  description = "Determines whether to attach the Load Balancer Controller policy for the TargetGroupBinding only"
  type        = bool
  default     = false
}

variable "load_balancer_controller_targetgroup_arns" {
  description = "List of Target groups ARNs using Load Balancer Controller"
  type = list(string)
  default = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
}

# AWS Appmesh Controller
variable "attach_appmesh_controller_policy" {
  description = "Determines whether to attach the Appmesh Controller policy to the role"
  type        = bool
  default     = false
}

# AWS Appmesh envoy proxy
variable "attach_appmesh_envoy_proxy_policy" {
  description = "Determines whether to attach the Appmesh envoy proxy policy to the role"
  type        = bool
  default     = false
}

# Amazon Managed Service for Prometheus
variable "attach_amazon_managed_service_prometheus_policy" {
  description = "Determines whether to attach the Amazon Managed Service for Prometheus IAM policy to the role"
  type        = bool
  default     = false
}

variable "amazon_managed_service_prometheus_workspace_arns" {
  description = "List of AMP Workspace ARNs to read and write metrics"
  type = list(string)
  default = ["*"]
}

# Velero
variable "attach_velero_policy" {
  description = "Determines whether to attach the Velero IAM policy to the role"
  type        = bool
  default     = false
}

variable "velero_s3_bucket_arns" {
  description = "List of S3 Bucket ARNs that Velero needs access to in order to backup and restore cluster resources"
  type = list(string)
  default = ["*"]
}

# VPC CNI
variable "attach_vpc_cni_policy" {
  description = "Determines whether to attach the VPC CNI IAM policy to the role"
  type        = bool
  default     = false
}

variable "vpc_cni_enable_cloudwatch_logs" {
  description = "Determines whether to enable VPC CNI permission to create CloudWatch Log groups and publish network policy events"
  type        = bool
  default     = false
}

variable "vpc_cni_enable_ipv4" {
  description = "Determines whether to enable IPv4 permissions for VPC CNI policy"
  type        = bool
  default     = true
}

variable "vpc_cni_enable_ipv6" {
  description = "Determines whether to enable IPv6 permissions for VPC CNI policy"
  type        = bool
  default     = false
}

# Node termination handler
variable "attach_node_termination_handler_policy" {
  description = "Determines whether to attach the Node Termination Handler policy to the role"
  type        = bool
  default     = false
}

variable "node_termination_handler_sqs_queue_arns" {
  description = "List of SQS ARNs that contain node termination events"
  type = list(string)
  default = ["*"]
}

# Amazon CloudWatch Observability
variable "attach_cloudwatch_observability_policy" {
  description = "Determines whether to attach the Amazon CloudWatch Observability IAM policies to the role"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "A map of tags to add the the IAM role"
  type = map(any)
  default = {}
}
