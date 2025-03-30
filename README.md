# Terraform을 통한 CI/CD 구성 및 EKS Self-managed Node 배포

## 전체 구성 다이어그램

![전체 구성 다이어그램](https://github.com/user-attachments/assets/83bcab22-3022-4b04-a260-fead906c70e9)

## 구성 요소 설명

### Terraform으로 생성되는 리소스
- **VPC**: AWS VPC를 생성하여 네트워크 환경을 구성
- **Subnet**: VPC 내 서브넷을 정의
- **보안그룹(Security Group)**: EKS와 EC2 인스턴스를 위한 보안그룹 생성
- **EC2**: EKS 클러스터의 self-managed 워커 노드를 위한 EC2 인스턴스 생성
- **IAM 역할**: EKS와 EC2 인스턴스를 위한 IAM 역할 및 정책 생성
- **KEY**: EC2 접근을 위한 SSH Key 생성
- **S3**: 아티팩트를 저장하기 위한 S3 버킷 생성
- **ECR**: Docker 이미지를 저장할 ECR 레지스트리 생성
- **CodePipeline**: CI/CD 파이프라인을 정의하여 소스 코드 변경 시 자동화된 빌드 및 배포 프로세스 구성
- **EC2**: Self-Managed Node로 사용하기 위한 인스턴스 구성
- **EKS**: EKS 클러스터를 생성하여 Kubernetes 환경을 설정

### Self-managed Node 구성
- **Self-managed EKS Node**: EC2 인스턴스를 EKS 클러스터에 워커 노드로 추가하여 self-managed 노드를 구성

### Ansible 사용
- **Ansible Playbook**: EC2 인스턴스에 Ansible을 사용하여 초기 설정 및 배포 작업 수행

## 작업 흐름
1. **GitHub Commit**: 사용자가 GitHub 저장소에 코드를 푸시합니다.
2. **CodePipeline Trigger**: GitHub과 연결된 CodePipeline이 이를 감지하여 빌드 프로세스를 시작합니다.
3. **CodeBuild**: CodeBuild에서 코드를 빌드하고, 결과물을 S3에 저장합니다.
4. **ECR 푸시**: 빌드된 Docker 이미지를 ECR에 푸시합니다.
5. **EKS 배포**: ECR의 이미지를 사용하여 EKS 클러스터에 배포합니다.
6. **ArgoCD**: ArgoCD가 Kubernetes 클러스터에서 배포 작업을 자동으로 관리합니다.

### CI/CD 프로세스 다이어그램
![CI/CD/ 프로세스 다이어그램](https://github.com/user-attachments/assets/d0cabeef-0e99-4927-835e-fdded0f364a4)  
**1. GitHub에 코드 푸시 → CodePipeline 트리거**  
**2. CodeBuild에서 빌드 수행 및 아티팩트 S3 업로드**  
**3. EKS 클러스터 및 Self-managed Node에 배포 진행**  

### 순서
`terraform apply`
