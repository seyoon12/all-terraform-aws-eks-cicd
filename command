curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo 'alias k="kubectl"' >> ~/.bashrc
echo 'alias kns="kubectl config set-context --current --namespace"' >> ~/.bashrc
source ~/.bashrc

# local
aws eks update-kubeconfig --region ap-northeast-2 --name kubernetes

kubectl patch serviceaccount aws-node \
  -n kube-system \
  -p '{"metadata": {"annotations": {"eks.amazonaws.com/role-arn": "arn:aws:iam::535597585675:role/aws-node-irsa-role"}}}'

eksctl utils associate-iam-oidc-provider   --region ap-northeast-2   --cluster kubernetes   --approve





