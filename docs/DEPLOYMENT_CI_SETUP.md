### 프로덕션 자동배포/프로덕션 E2E 세팅 가이드

#### 1) 필요한 GitHub Secrets
- RAILS_MASTER_KEY: Rails 마스터 키
- KAMAL_SSH_PRIVATE_KEY: 서버 접속용 SSH 개인키 (deploy 사용자)
- KAMAL_REGISTRY_USERNAME: 컨테이너 레지스트리 계정
- KAMAL_REGISTRY_PASSWORD: 컨테이너 레지스트리 토큰/비밀번호
- (선택) KAMAL_REGISTRY_SERVER: ghcr.io 혹은 사설 레지스트리 주소
- (선택) KAMAL_PROXY_HOST: 프록시 도메인(예: xn--2i4b17iihloh20d.kr)

#### 2) config/deploy.yml 확인 포인트
- image: 컨테이너 이미지 네임스페이스(user/repo) 업데이트
- servers: 프로덕션 서버 IP/호스트 세팅
- proxy.host: 프로덕션 도메인(정화의서재.kr의 punycode: xn--2i4b17iihloh20d.kr)
- registry: 서버/username 비워두면 Docker Hub 기본 사용

#### 3) 워크플로우
- .github/workflows/deploy-prod.yml
  - main 푸시 또는 수동 실행 시 Kamal로 빌드/배포
- .github/workflows/e2e-prod.yml
  - 배포 완료 후 프로덕션 도메인 대상 Playwright E2E 실행
- .github/workflows/ci.yml
  - PR/메인 푸시 시 브레이크맨 + Playwright 스모크

#### 4) 실행 흐름
1) main에 머지 → Deploy to Production (Kamal) 자동 실행 → 성공 시 E2E on Production 자동 실행
2) 수동 실행: Actions 탭에서 각 워크플로우 "Run workflow" 사용 가능

#### 5) 주의
- 최초 배포는 방화벽/포트, Docker/SSH 권한 세팅 필요
- 결제 관련 키/도메인 콜백 URL은 운영 키/도메인으로 설정


