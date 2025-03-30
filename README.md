## Terraform을 통한 CodePipeline CI 구성 및 EKS + Self-managed Node 배포

### 전체 구성 다이어그램
<img src="https://github.com/user-attachments/assets/83bcab22-3022-4b04-a260-fead906c70e9" width="600"/>


### CI/CD 프로세스 다이어그램
<img src="https://github.com/user-attachments/assets/d0cabeef-0e99-4927-835e-fdded0f364a4" width="600"/>
1) GitHub에 코드 푸시 → CodePipeline 트리거
2) CodeBuild에서 빌드 수행 및 아티팩트 S3 업로드
3) EKS 클러스터 및 Self-managed Node에 배포 진행
