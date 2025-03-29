provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc-module"
}

module "keypair" {
  source = "./keyPair-module"
}

module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
}

module "s3" {
  source      = "./s3-module"
  bucket_name = "codepipeline-ci-seyoon"
}

module "ecr" {
  source          = "./ecr-module"
  repository_name = "app-ecr"
}

module "iam_codebuild" {
  codepipeline_role_name = module.iam_codepipeline.codepipeline_role_name
  source = "./iam-module/codebuild"
}

module "iam_codepipeline" {
  source = "./iam-module/codepipeline"
}

module "iam_eks_cluster" {
  source = "./iam-module/eks-cluster"
}

module "iam_eks_node" {
  source = "./iam-module/eks-node"
}

module "iam_eks_master" {
  source = "./iam-module/eks-master"
  trusted_role_arn = module.iam_eks_node.eks_node_role_arn
}
module "codebuild" {
  source            = "./codebuild-module"
  service_role_arn  = module.iam_codebuild.codebuild_role_arn
  repository_uri    = module.ecr.repository_url
}

module "codepipeline" {
  source                   = "./codepipeline_ci-module"
  pipeline_name            = "codepipeline_ci"
  artifact_bucket          = module.s3.bucket_name
  codebuild_project_name   = module.codebuild.codebuild_project_name
  role_arn                 = module.iam_codepipeline.codepipeline_role_arn
  ecr_repository_url       = module.ecr.repository_url
  aws_region               = var.aws_region
  github_oauth_token       = var.github_oauth_token
  github_repo              = var.github_repo
  github_owner             = var.github_owner
  github_branch            = var.github_branch
} 

resource "aws_eks_cluster" "kubernetes" {
  name     = var.cluster_name                    
  role_arn = module.iam_eks_cluster.cluster_role_arn          
  version  = "1.29"

  vpc_config {
    subnet_ids = module.vpc.public_subnet_ids    
  }
depends_on = [module.iam_eks_cluster.eks_cluster_policy_attachment]
}

data "aws_eks_cluster" "selected" {
  name = "kubernetes"

  depends_on = [aws_eks_cluster.kubernetes]
}

data "aws_eks_cluster_auth" "selected" {
  name = "kubernetes"

  depends_on = [aws_eks_cluster.kubernetes]
}

  module "eks_self_managed_node_group" {
    source = "./eks-selfmanaged-module"
    eks_cluster_endpoint   = data.aws_eks_cluster.selected.endpoint
    eks_cluster_ca         = data.aws_eks_cluster.selected.certificate_authority[0].data
    eks_cluster_token      = data.aws_eks_cluster_auth.selected.token
    eks_cluster_name = "kubernetes"
    instance_type    = "t3.medium"
    desired_capacity = 1
    min_size         = 1
    max_size         = 1
    subnets          = module.vpc.public_subnet_ids
    key_name         = module.keypair.k8s_keyname
    
    node_labels = {
      "node.kubernetes.io/node-group" = "node-group-a"
    }
  }




resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks_self_managed_node_group.role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes",
          "system:masters"
        ]
      }
    ])
  }
}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = yamlencode([
#       {
#         rolearn  = module.iam_eks_node.eks_node_role_arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       },
#       {
#         rolearn  = module.iam_eks_master.eks_admin_role_arn
#         username = "eks-admin"
#         groups   = ["system:masters"]
#       }
#     ])

#     mapUsers = yamlencode([
#       {
#         userarn  = "arn:aws:iam::535597585675:user/terraform"
#         username = "terraform"
#         groups   = ["system:masters"]
#       }
#     ])
#   }

#   depends_on = [module.eks]
# }

# module "eks_node_group" {
#   source                   = "./eks-node-module"
#   instance_type            = var.instance_type
#   ami                      = var.ami  
#   cluster_name             = var.cluster_name
#   key_name                 = module.keypair.k8s_keyname
#   availability_zone        = module.vpc.availability_zone_0
#   subnet_id                = module.vpc.public_subnet_id
#   instance_profile_name    = module.iam_eks_node.eks_node_instance_profile  
#   security_group_ids       = [module.sg.workernodes_sg_group_ids]
# }



# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.0"

#   cluster_name    = "kubernetes"
#   cluster_version = "1.30"

#   enable_cluster_creator_admin_permissions = true
#   cluster_endpoint_public_access           = true

#   cluster_addons = {
#     coredns    = {}
#     kube-proxy = {}
#     vpc-cni    = {}
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.public_subnet_ids

#   self_managed_node_groups = {
#     default = {
#       instance_type              = "t3.medium"
#       ami_type                   = "AL2023_x86_64_STANDARD"
#       iam_instance_profile_name  = module.iam_eks_node.eks_node_instance_profile
#       key_name                   = module.keypair.k8s_keyname
#       enable_irsa = true
#       min_size                   = 1
#       max_size                   = 1
#       desired_size               = 1
#       associate_public_ip_address = true
#       additional_security_group_ids = [module.sg.workernodes_sg_group_ids]
#     }
#   }

#   tags = {
#     Environment = "test"
#     Project     = "eks-cluster"
#   }
# }

# module "vpc_cni_irsa_role" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name = "vpc-cni"

#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }
# }