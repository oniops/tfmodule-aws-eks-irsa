# variable "cluster_name" {
#   type = string
#   description = "The name of EKS Cluster"
# }
# variable "cluster_simple_name" {
#   type = string
#   description = "The simple name of EKS Cluster"
# }

variable "eks_context" {
  type = object({
    account_id                = string
    region                    = string
    project                   = string
    owner                     = string
    team                      = string
    domain                    = string
    pri_domain                = string
    name_prefix               = string
    tags                      = map(string)

    # EKS
    cluster_name              = string
    cluster_simple_name       = string
    cluster_version           = string
    cluster_endpoint          = string
    cluster_auth_base64       = string
    service_ipv4_cidr         = string
    node_security_group_id    = string
  })
  description = <<-EOF

module "ctx" {
  source          = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.0"
  context         = var.context
  eks_simple_name = var.cluster_simple_name
}

eks_context = module.ctx.eks_context

EOF

}