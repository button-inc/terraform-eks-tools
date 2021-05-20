# Terraform EKS tools

Terraform module which creates Kubernetes tools on AWS EKS.

- `ALB Ingress Controller`: This module can install the ALB Ingress controller into AWS-managed EKS clusters.

  - see https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  - see https://github.com/kubernetes-sigs/aws-load-balancer-controller
  - see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/

- `External DNS`: This module can install the External DNS into AWS-managed EKS clusters.
  - see https://github.com/kubernetes-sigs/external-dns
  - see https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
  - see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/integrations/external_dns/

## Usage

```hcl
module "eks_tools" {
  source  = "button-inc/tools/eks"
  cluster_id = "eks-dev"
}
```

## Authors

Module is maintained by [Junmin Ahn](https://github.com/junminahn).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/LICENSE) for full details.
