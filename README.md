## Terraform을 통한 CodePipeline CI 구성 및 EKS + Self-managed Node 배포

# Terraform을 통한 CI/CD 구성 및 EKS Self-managed Node 배포

## 전체 구성 다이어그램

![전체 구성 다이어그램](https://github.com/user-attachments/assets/83bcab22-3022-4b04-a260-fead906c70e9)

이 다이어그램은 Terraform과 Ansible을 사용하여 EKS 클러스터와 CI/CD 환경을 구성하는 전체 흐름을 나타낸다.

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
- **EKS**: EKS 클러스터를 생성하여 Kubernetes 환경을 설정

### Self-managed Node 구성
- **Self-managed EKS Node**: EC2 인스턴스를 EKS 클러스터에 워커 노드로 추가하여 self-managed 노드를 구성

### CI/CD 파이프라인
- **CodePipeline**: GitHub 저장소의 변경 사항을 감지하여 빌드와 배포를 자동화
- **GitHub 연결**: CodePipeline에서 GitHub과 연결하여 소스 코드 변경을 감지
- **S3 Artifact 저장**: 빌드 후 생성된 아티팩트를 S3에 저장
- **ECR 푸시**: Docker 이미지를 ECR에 푸시하여 Kubernetes 클러스터에 배포
- **ArgoCD 배포**: ArgoCD를 통해 Kubernetes 클러스터에 자동 배포

### Ansible 사용
- **Ansible Playbook**: EC2 인스턴스에 Ansible을 사용하여 초기 설정 및 배포 작업 수행

## 작업 흐름

1. **GitHub Commit**: 사용자가 GitHub 저장소에 코드를 푸시합니다.
2. **CodePipeline Trigger**: GitHub과 연결된 CodePipeline이 이를 감지하여 빌드 프로세스를 시작합니다.
3. **CodeBuild**: CodeBuild에서 코드를 빌드하고, 결과물을 S3에 저장합니다.
4. **ECR 푸시**: 빌드된 Docker 이미지를 ECR에 푸시합니다.
5. **EKS 배포**: ECR의 이미지를 사용하여 EKS 클러스터에 배포합니다.
6. **ArgoCD**: ArgoCD가 Kubernetes 클러스터에서 배포 작업을 자동으로 관리합니다.

## 설치 및 사용

1. **Terraform 설치**: Terraform을 설치하여 인프라 리소스를 관리합니다.
2. **Ansible 설치**: Ansible을 설치하여 EC2 인스턴스에 배포 작업을 자동화합니다.
3. **GitHub와 연결**: GitHub 저장소와 CodePipeline을 연결하여 소스 변경 사항을 감지합니다.
4. **EKS 클러스터 설정**: EKS 클러스터를 Terraform으로 생성하고, self-managed 워커 노드를 EC2 인스턴스로 설정합니다.
5. **CI/CD 파이프라인 구성**: CodePipeline을 구성하여 CI/CD 파이프라인을 완성합니다.


### 전체 구성 다이어그램
<img src="https://github.com/user-attachments/assets/83bcab22-3022-4b04-a260-fead906c70e9" width="600"/>


### CI/CD 프로세스 다이어그램
<img src="https://github.com/user-attachments/assets/d0cabeef-0e99-4927-835e-fdded0f364a4" width="600"/>
1) GitHub에 코드 푸시 → CodePipeline 트리거
2) CodeBuild에서 빌드 수행 및 아티팩트 S3 업로드
3) EKS 클러스터 및 Self-managed Node에 배포 진행
