# Google Cloud 완전 배포 가이드 - 정화의서재

**계정 구조:**
- GCP: jjunghwa520@gmail.com
- GitHub: jjunghwa520@gmail.com
- 도메인: 정화의서재.kr (가비아)
- DNS: Cloudflare (이미 연동됨)

**목표:** 실서비스 배포  
**시간:** 2-3시간  
**비용:** 월 ₩20,000-40,000

---

## ✅ 이미 완료된 것

```
✅ 도메인 구매: 정화의서재.kr (가비아)
✅ Cloudflare 연동: 네임서버 변경 완료
✅ Cloudflare API Token: 생성 완료
✅ Zone ID: 173b110305a65f8392f54ea55c116867
```

---

## 🎯 Phase 1: GCP 프로젝트 생성 (사용자 작업)

### Step 1-1: GCP Console 접속

```
1. https://console.cloud.google.com 접속

2. 구글 로그인
   - 계정: jjunghwa520@gmail.com
   - 비밀번호: wjdghk81@

3. (처음이면) 무료 평가판 활성화
   - $300 무료 크레딧 (90일)
   - 신용카드 등록 필요
   - 자동 청구 안 됨 (확인 후 전환)
```

### Step 1-2: 새 프로젝트 생성

```
1. 상단 프로젝트 선택 드롭다운 클릭

2. "새 프로젝트" 클릭

3. 프로젝트 정보 입력:
   - 프로젝트 이름: jeonghwa-library-prod
   - 프로젝트 ID: jeonghwa-library-prod (자동 생성됨)
   - 위치: 조직 없음

4. "만들기" 클릭

5. 생성 완료 대기 (1-2분)

6. 프로젝트 선택 (상단 드롭다운)
```

**저장할 정보:**
```
📌 프로젝트 ID: jeonghwa-library-prod (또는 생성된 ID)
📌 프로젝트 번호: (대시보드에서 확인)
```

### Step 1-3: 결제 계정 설정

```
1. 좌측 메뉴 → "결제"

2. "결제 계정 연결" 또는 "결제 사용 설정"

3. 결제 정보 입력:
   - 계정 유형: 개인 또는 사업자
   - 국가: 대한민국
   - 신용카드 정보
   - 주소

4. "제출 및 결제 사용 설정"

완료!
```

### Step 1-4: 필수 API 활성화

```
1. 좌측 메뉴 → "API 및 서비스" → "라이브러리"

2. 다음 API 검색 및 활성화:

   ✅ Cloud Run API
      검색 → "Cloud Run" → "사용 설정" 클릭

   ✅ Cloud Build API
      검색 → "Cloud Build" → "사용 설정"

   ✅ Cloud Storage API
      검색 → "Cloud Storage" → "사용 설정"

   ✅ Artifact Registry API
      검색 → "Artifact Registry" → "사용 설정"

   ✅ Vertex AI API (이미지 생성용)
      검색 → "Vertex AI" → "사용 설정"

각각 활성화하는데 10-30초 소요
총 2-3분
```

---

## 🎯 Phase 2: Cloud Storage 설정 (사용자 작업)

### Step 2-1: 버킷 생성

```
1. 좌측 메뉴 → "Cloud Storage" → "버킷"

2. "만들기" 클릭

3. 버킷 설정:
   - 이름: jeonghwa-assets ⭐
   - 위치 유형: 리전
   - 위치: asia-northeast3 (Seoul) ⭐
   - 스토리지 클래스: Standard
   - 액세스 제어: 균일
   - 보호 도구: 기본값

4. "만들기" 클릭

완료!
```

### Step 2-2: 공개 액세스 설정

```
1. 생성된 버킷 (jeonghwa-assets) 클릭

2. 상단 "권한" 탭

3. "주 구성원 추가" 클릭

4. 설정:
   - 새 주 구성원: allUsers
   - 역할: Storage 객체 뷰어

5. "저장" 클릭

6. 경고 나오면 "공개 허용" 클릭

완료! (이미지가 공개적으로 접근 가능해짐)
```

---

## 🎯 Phase 3: GitHub 저장소 설정 (사용자 작업)

### Step 3-1: GitHub 가입

```
1. https://github.com 접속

2. "Sign up" 클릭

3. 구글 계정으로 가입:
   - "Continue with Google" 클릭
   - jjunghwa520@gmail.com 선택
   - 권한 허용

또는 이메일로 직접 가입:
   - Email: jjunghwa520@gmail.com
   - Password: (새로 설정)
   - Username: jeonghwa-library (추천)

4. 이메일 인증

5. 로그인
```

### Step 3-2: 새 저장소 생성

```
1. 우측 상단 "+" → "New repository"

2. 저장소 설정:
   - Owner: jeonghwa-library (본인 계정)
   - Repository name: jeonghwa-library ⭐
   - Description: 정화의서재 - 어린이 동화 플랫폼
   - 가시성: Private ✅ (중요!)
   - README 추가: 체크 안 함

3. "Create repository" 클릭
```

**저장할 정보:**
```
📌 GitHub 계정: jeonghwa-library (또는 username)
📌 저장소: jeonghwa-library/jeonghwa-library
📌 저장소 URL: https://github.com/username/jeonghwa-library
```

### Step 3-3: 현재 코드 푸시

```bash
# 로컬에서 실행
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# Git 초기화 (아직 안 했다면)
git init

# GitHub 저장소 연결
git remote add origin https://github.com/username/jeonghwa-library.git

# 제외 파일 확인 (.gitignore)
cat .gitignore
# ✅ config/master.key
# ✅ .env*
# ✅ config/google_service_account.json

# 커밋
git add .
git commit -m "Initial commit: 정화의서재 프로젝트"

# 푸시
git push -u origin main

# GitHub에서 확인
# https://github.com/username/jeonghwa-library
```

---

## 🎯 Phase 4: GCP Service Account (AI 자동화용)

### Step 4-1: Service Account 생성 (사용자 작업)

```
1. GCP Console → IAM 및 관리자 → 서비스 계정

2. "+ 서비스 계정 만들기" 클릭

3. 서비스 계정 세부정보:
   - 이름: github-actions-deploy
   - ID: github-actions-deploy (자동)
   - 설명: GitHub Actions 자동 배포용

4. "만들기 및 계속하기"

5. 역할 부여 (3개):
   - Cloud Run 관리자
   - Storage 관리자
   - Cloud Build 편집자

6. "계속" → "완료"
```

### Step 4-2: 키 생성

```
1. 생성된 서비스 계정 클릭
   (github-actions-deploy@...)

2. 상단 "키" 탭

3. "키 추가" → "새 키 만들기"

4. 키 유형: JSON ✅

5. "만들기" 클릭

6. JSON 파일 다운로드됨
   예: jeonghwa-library-prod-xxxxx.json

⚠️ 이 파일 안전하게 보관!
```

---

## 🎯 Phase 5: GitHub Actions 설정 (사용자 작업)

### Step 5-1: GitHub Secrets 추가

```
1. GitHub 저장소 페이지

2. Settings → Secrets and variables → Actions

3. "New repository secret" 클릭

4. Secret 추가 (4개):

   이름: GCP_PROJECT_ID
   값: jeonghwa-library-prod
   
   이름: GCP_SA_KEY
   값: (다운로드한 JSON 파일 전체 내용 붙여넣기)
   
   이름: RAILS_MASTER_KEY
   값: (config/master.key 파일 내용)
   
   이름: CLOUDFLARE_API_TOKEN
   값: ge0s_pYVROWkOqzxWxIH34Pki_KmWYVbkfTwsE7q
   
   이름: CLOUDFLARE_ZONE_ID
   값: 173b110305a65f8392f54ea55c116867

5. 각각 "Add secret" 클릭
```

---

## 🤖 Phase 6: AI 자동 생성 (제가 할 것)

**사용자가 위 단계 완료 후 다음 정보만 전달:**

```yaml
gcp_info:
  project_id: "jeonghwa-library-prod"
  project_number: "123456789012"  # 대시보드에서 확인
  region: "asia-northeast3"
  bucket: "jeonghwa-assets"

github_info:
  username: "jeonghwa-library"  # 또는 본인 username
  repo: "jeonghwa-library"
```

**제가 자동으로 생성:**

1. ✅ `.github/workflows/deploy.yml`
   - GitHub Actions 자동 배포

2. ✅ `cloudbuild.yaml`
   - Cloud Build 설정

3. ✅ `config/storage.yml`
   - Cloud Storage 연동

4. ✅ `app.yaml`
   - Cloud Run 설정

5. ✅ `deploy.sh`
   - 배포 스크립트

6. ✅ 완전 문서화

---

## 📋 현재 진행 상황

### ✅ 완료
```
✅ 도메인: 정화의서재.kr
✅ Cloudflare 연동
✅ Zone ID/API Token 확보
✅ 계정 구조 결정
```

### 📝 사용자 작업 필요 (1-2시간)
```
1. GCP 프로젝트 생성
2. API 활성화 (6개)
3. Cloud Storage 버킷 생성
4. Service Account 생성 및 키 다운로드
5. GitHub 가입 및 저장소 생성
6. GitHub Secrets 추가
7. 프로젝트 ID/번호 전달
```

### 🤖 AI 자동 작업 (즉시)
```
→ 정보 받으면 모든 설정 파일 자동 생성
→ 배포 스크립트 작성
→ 문서화 완료
```

---

## 🚀 빠른 시작 가이드

### 오늘 할 일

```
1. GCP Console 접속 및 프로젝트 생성 (10분)
2. API 활성화 (5분)
3. Cloud Storage 버킷 생성 (5분)
4. Service Account 생성 (10분)
5. GitHub 가입 및 저장소 생성 (10분)
6. GitHub Secrets 설정 (10분)
7. 정보 정리해서 AI에게 전달 (5분)

총: 55분
```

### AI가 할 일

```
→ 설정 파일 전부 자동 생성 (즉시)
→ 배포 가이드 작성
→ 첫 배포 준비 완료
```

---

## 💡 다음 작업

**지금 바로 시작:**
1. https://console.cloud.google.com 접속
2. 새 프로젝트 생성: "jeonghwa-library-prod"
3. 프로젝트 ID 확인 후 알려주세요

그러면 다음 단계를 상세히 안내해드리겠습니다! 🚀

**또는 한 번에 진행하시겠어요?**
- 모든 단계를 한 번에 완료하신 후
- 프로젝트 ID/번호만 알려주시면
- 제가 바로 배포 설정 생성하겠습니다!

어떤 방식을 선호하시나요? 😊

