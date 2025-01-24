variable "cluster_name" {
  type = string
  description = "The name of EKS Cluster"
}

variable "cluster_simple_name" {
  type = string
  description = "The simple name of EKS Cluster"
}

variable "context" {
  type = object({
    account_id          = string
    region              = string
    project             = string
    environment         = string
    owner               = string
    team                = string
    name_prefix         = string
    s3_bucket_prefix    = string
    pri_domain          = string
    tags = map(string)
  })
  description =<<-EOF
Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project.

  eks_context = merge(module.ctx.context, {
    cluster_name           = local.cluster_name
    cluster_simple_name    = local.cluster_simple_name
    cluster_version        = data.aws_eks_cluster.this.version
    cluster_endpoint       = data.aws_eks_cluster.this.endpoint
    cluster_auth_base64    = data.aws_eks_cluster.this.certificate_authority[0].data
    service_ipv4_cidr      = data.aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr
    node_security_group_id = data.aws_security_group.node.id
  })
EOF
}
