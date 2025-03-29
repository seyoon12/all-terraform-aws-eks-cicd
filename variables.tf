variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "ami" {
  description = "eks-node-ubuntu-22.04"
  type        = string
  default     = "ami-000635c8c2be72d0d"
}

variable "instance_type" {
  description = "t3.medium"
  default = "t3.medium"
  type        = string
}

variable "admin_user" {
  default = "wntpqhd1326"
  type        = string
  description = "Admin IAM user name"
}

variable "github_owner" {
  default   = "seyoon12"
  type        = string
}

variable "github_repo" {
  default   = "all-terraform-aws-eks-cicd"
  type        = string
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "cluster_name" {
  default = "kubernetes"
  type = string
}

variable "tags" {
  type        = map(any)
  default     = {}
}

variable "node_labels" {
  type        = map(any)
  default     = {}
}

variable "key_name" {
  type        = string
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
}