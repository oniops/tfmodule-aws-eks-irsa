# tfmodule-aws-eks-irsa

이 모듈은 [iam-role-for-service-accounts-eks](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks) 오픈소스 프로젝트를 참고 하여, 
IRSA(IAM Role for Service Accounts) 인증을 구성합니다. 
EKS 위에 실행되는 애플리케이션은 Kubernetes Service Account를 통해 AWS IAM Role을 수임하여 클라우드 리소스를 액세스 할 수 있습니다.

EKS 내에서 일반적으로 사용되는 컨트롤러/사용자 정의 리소스에 대한 선택적 정책과 함께 AWS EKS `ServiceAccount`에서 가정할 수 있는 IAM 역할을 만듭니다. 

다음은 EKS 에서 IRSA를 통해 AWS 리소스를 액세스하는 주요 서비스 및 플러그인 입니다.
- [Cert-Manager](https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-role)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/example-iam-policy.json)
- [EFS CSI Driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-example.json)
- [External DNS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy)
- [External Secrets](https://github.com/external-secrets/kubernetes-external-secrets#add-a-secret)
- [FSx for Lustre CSI Driver](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/docs/README.md)
- [Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json)
    - [Load Balancer Controller Target Group Binding Only](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#iam-permission-subset-for-those-who-use-targetgroupbinding-only-and-dont-plan-to-use-the-aws-load-balancer-controller-to-manage-security-group-rules)
- [App Mesh Controller](https://github.com/aws/aws-app-mesh-controller-for-k8s/blob/master/config/iam/controller-iam-policy.json)
    - [App Mesh Envoy Proxy](https://raw.githubusercontent.com/aws/aws-app-mesh-controller-for-k8s/master/config/iam/envoy-iam-policy.json)
- [Managed Service for Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html)
- [Mountpoint S3 CSI Driver](https://github.com/awslabs/mountpoint-s3/blob/main/doc/CONFIGURATION.md#iam-permissions)
- [Node Termination Handler](https://github.com/aws/aws-node-termination-handler#5-create-an-iam-role-for-the-pods)
- [Velero](https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user)
- [VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html)


## Usage 

이 모듈을 통해 EKS 에서 실행되는 다양한 애플리케이션들이 각자의 AWS 클라우드 리소스를 액세스 하기위한 IRSA 인증 체계를 구성하여 제어합니다.

 

### IRSA for App
EKS 내의  `my-app-staging` SA(Service Account)가 IRSA 인증을 통해 myAppRole 역할을 생성 및 통합하는 예시입니다.  

```hcl
module "irsa" {  
  source    = "git::https://github.com/oniops/tfmodule-aws-eks-irsa.git?ref=v1.2.0"
  context   = var.context
  name      = "myAppRole"
  
  role_policy_arns = {
    myAppRoleEC2Policy = "arn:aws:iam::111122223333:policy/myAppRoleEC2Policy"
    myAppRoleS3Policy  = "arn:aws:iam::111122223333:policy/myAppRoleS3Policy"
  }

  oidc_provider = {
    provider_arn = "arn:aws:iam::111122223333:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
    namespace_service_accounts = [ "default:my-app-staging", "canary:my-app-staging" ]
  }
}
```

### IRSA for VpcCNI

```hcl
module "irsaCniVpc" {
  source                = "git::https://github.com/oniops/tfmodule-aws-eks-irsa.git?ref=v1.2.0"
  eks_context           = module.ctx.eks_context
  name                  = "VpcCniDriver"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  oidc_provider = {
    provider_arn = module.ctx.eks_oidc_provider_arn # "arn:aws:iam::111122223333:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
    namespace_service_accounts = [ "kube-system:aws-node" ]
  }
}

### IRSA for CertManager

module "irsaCertManager" {
  source                     = "git::https://github.com/oniops/tfmodule-aws-eks-irsa.git?ref=v1.2.0"
  eks_context                = module.ctx.eks_context
  name                       = "certManager"
  attach_cert_manager_policy = true
  oidc_provider = {
    provider_arn                = module.ctx.eks_oidc_provider_arn
    namespace_service_accounts  = [ "certmanager:certmanager" ]
  }
}

### IRSA for EbsCsiDriver

module "irsaEbsCsi" {
  source                = "git::https://github.com/oniops/tfmodule-aws-eks-irsa.git?ref=v1.2.0"
  eks_context           = module.ctx.eks_context
  name                  = "EbsCsiDriver"
  attach_ebs_csi_policy = true
  ebs_csi_kms_ids       = [data.aws_kms_alias.YOUR_KMS.target_key_arn]
  oidc_provider = {
    provider_arn        = module.ctx.eks_oidc_provider_arn
    namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
  }
}

```
