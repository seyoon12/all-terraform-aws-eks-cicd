output "k8s_private_key" {
  value     = module.keypair.k8s_private_key
  sensitive = true
}

output "github_oauth_token" {
  value = var.github_oauth_token
  sensitive = true
}
