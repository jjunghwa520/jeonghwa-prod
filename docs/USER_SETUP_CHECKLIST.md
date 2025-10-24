# 사용자 작업 체크리스트 - GCP & GitHub 설정

**목표:** GCP 프로젝트와 GitHub 저장소 준비  
**시간:** 1시간  
**완료 후:** AI가 모든 배포 파일 자동 생성

---

## 📋 Part 1: GCP 프로젝트 생성 (30분)

### ✅ Step 1: GCP 접속 및 로그인

```
□ https://console.cloud.google.com 접속
□ 구글 로그인: jjunghwa520@gmail.com
□ (처음이면) 무료 평가판 시작 ($300 크레딧)
```

### ✅ Step 2: 새 프로젝트 생성

```
□ 상단 프로젝트 선택 드롭다운 클릭
□ "새 프로젝트" 클릭
□ 프로젝트 이름: jeonghwa-library-prod
□ "만들기" 클릭
□ 생성 완료 대기 (1-2분)
□ 프로젝트 선택
```

**📌 여기서 확인:**
```
프로젝트 ID: _________________________
프로젝트 번호: _________________________
```

### ✅ Step 3: 결제 계정 연결

```
□ 좌측 메뉴 → "결제"
□ "결제 계정 연결" 클릭
□ 신용카드 정보 입력
□ 국가: 대한민국
□ "제출" 클릭
```

### ✅ Step 4: API 활성화 (중요!)

**좌측 메뉴 → "API 및 서비스" → "라이브러리"**

각각 검색 후 "사용 설정" 클릭:

```
□ Cloud Run API
□ Cloud Build API  
□ Cloud Storage API
□ Artifact Registry API
□ Vertex AI API
□ Secret Manager API
```

---

## 📋 Part 2: Cloud Storage 버킷 생성 (10분)

### ✅ Step 5: 버킷 생성

```
□ 좌측 메뉴 → "Cloud Storage" → "버킷"
□ "만들기" 클릭
□ 이름: jeonghwa-assets (정확히!)
□ 위치 유형: 리전
□ 위치: asia-northeast3 (Seoul) 선택
□ 스토리지 클래스: Standard
□ 액세스 제어: 균일
□ "만들기" 클릭
```

### ✅ Step 6: 공개 액세스 설정

```
□ 버킷 (jeonghwa-assets) 클릭
□ "권한" 탭 클릭
□ "주 구성원 추가" 클릭
□ 새 주 구성원: allUsers
□ 역할: Storage 객체 뷰어
□ "저장" 클릭
□ "공개 허용" 확인
```

---

## 📋 Part 3: Service Account (20분)

### ✅ Step 7: Service Account 생성

```
□ 좌측 메뉴 → "IAM 및 관리자" → "서비스 계정"
□ "+ 서비스 계정 만들기" 클릭
□ 이름: github-actions-deploy
□ 설명: GitHub Actions 자동 배포용
□ "만들기 및 계속하기" 클릭
```

### ✅ Step 8: 역할 부여 (3개)

```
□ 역할 추가:
   1. Cloud Run 관리자
   2. Storage 관리자
   3. Cloud Build 편집자
□ "계속" 클릭
□ "완료" 클릭
```

### ✅ Step 9: JSON 키 다운로드

```
□ 생성된 서비스 계정 클릭
□ "키" 탭 클릭
□ "키 추가" → "새 키 만들기"
□ 키 유형: JSON 선택
□ "만들기" 클릭
□ JSON 파일 다운로드됨
□ 파일 안전한 곳에 보관 ⚠️
```

**📌 다운로드한 파일:**
```
파일명: jeonghwa-library-prod-xxxxx.json
위치: ~/Downloads/
```

---

## 📋 Part 4: GitHub 설정 (20분)

### ✅ Step 10: GitHub 가입

```
□ https://github.com 접속
□ "Sign up" 클릭
□ "Continue with Google" 선택
□ jjunghwa520@gmail.com 선택
□ Username 선택: jeonghwa-library (추천)
□ 이메일 인증
```

**📌 GitHub username:**
```
Username: _________________________
```

### ✅ Step 11: 새 저장소 생성

```
□ 우측 상단 "+" → "New repository"
□ Repository name: jeonghwa-library
□ Description: 정화의서재 - 어린이 동화 플랫폼
□ Private 선택 ✅
□ README 추가: 체크 안 함
□ "Create repository" 클릭
```

### ✅ Step 12: GitHub Secrets 추가

**Settings → Secrets and variables → Actions**

"New repository secret" 5번 클릭하여 추가:

```
□ Secret 1:
   Name: GCP_PROJECT_ID
   Value: (Step 2에서 확인한 프로젝트 ID)

□ Secret 2:
   Name: GCP_SA_KEY
   Value: (Step 9 다운로드한 JSON 파일 전체 내용 복사/붙여넣기)

□ Secret 3:
   Name: RAILS_MASTER_KEY
   Value: (로컬 config/master.key 파일 내용)

□ Secret 4:
   Name: CLOUDFLARE_API_TOKEN
   Value: ge0s_pYVROWkOqzxWxIH34Pki_KmWYVbkfTwsE7q

□ Secret 5:
   Name: CLOUDFLARE_ZONE_ID
   Value: 173b110305a65f8392f54ea55c116867
```

**RAILS_MASTER_KEY 확인 방법:**
```bash
# 터미널에서
cat /Users/l2dogyu/KICDA/ruby/kicda-jh/config/master.key
# 나온 값 복사
```

---

## 📝 Part 5: 정보 정리 및 AI 전달

### 모든 작업 완료 후 다음 형식으로 전달:

```yaml
GCP 정보:
  프로젝트 ID: jeonghwa-library-prod
  프로젝트 번호: 123456789012
  리전: asia-northeast3
  버킷: jeonghwa-assets

GitHub 정보:
  Username: jeonghwa-library
  저장소: jeonghwa-library
  Secrets: 5개 추가 완료

확인:
  □ GCP API 6개 활성화 완료
  □ Cloud Storage 버킷 생성 완료
  □ Service Account JSON 키 다운로드
  □ GitHub Secrets 5개 추가 완료
```

---

## 🎯 완료 후 AI가 할 것

정보 받으면 제가 즉시:

```
1. ✅ cloudbuild.yaml 생성
2. ✅ .github/workflows/deploy.yml 생성
3. ✅ config/storage.yml 수정
4. ✅ config/environments/production.rb 수정
5. ✅ app.yaml 생성
6. ✅ deploy.sh 스크립트
7. ✅ DNS 자동 연결 스크립트
8. ✅ 이미지 업로드 스크립트
9. ✅ 완전 배포 문서
10. ✅ 롤백 스크립트
```

---

## 💰 예상 비용 (최종)

```
GCP Cloud Run: $10-20/월 (1,000명 사용자)
GCP Cloud Storage: $2-5/월 (30GB)
GCP 트래픽: $5-10/월
Cloudflare: 무료
도메인 (가비아): ₩1,500/월

총: $17-35/월 (₩23,000-47,000)
```

---

## ⚠️ 중요 체크

작업 중 꼭 확인:

```
✅ Service Account JSON 키 절대 GitHub에 푸시 금지!
✅ config/master.key 절대 GitHub에 푸시 금지!
✅ Cloud Storage 버킷 이름: jeonghwa-assets (정확히)
✅ 리전: asia-northeast3 (Seoul)
✅ GitHub 저장소: Private
```

---

**준비되셨으면 지금 바로 시작하세요!**

완료하시고 프로젝트 ID/번호만 알려주시면, 제가 모든 배포 파일을 자동 생성하겠습니다! 🚀

**막히는 부분이 있으면 즉시 질문해주세요!** 💬

