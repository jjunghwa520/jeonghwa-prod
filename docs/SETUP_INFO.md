# 배포 설정 정보 - 복사해서 사용하세요

**작성일:** 2025-10-23  
**용도:** GCP 및 GitHub 설정 시 복사/붙여넣기

---

## 📋 기본 정보

### 도메인
```
정화의서재.kr
```

### Cloudflare
```
Zone ID: 173b110305a65f8392f54ea55c116867
Account ID: 2956ab270a1eb55f32081df52a79357c
API Token: ge0s_pYVROWkOqzxWxIH34Pki_KmWYVbkfTwsE7q
```

### Rails
```
RAILS_MASTER_KEY: 71dfcbdae82a7dbd6f483bc635a1b024
```

---

## 🎯 GCP 프로젝트 설정값

### 프로젝트 생성 시
```
프로젝트 이름: jeonghwa-prod
리전 (기본): asia-northeast3 (Seoul)
```

### Cloud Storage 버킷
```
버킷 이름: jeonghwa-assets
위치: asia-northeast3 (Seoul)
스토리지 클래스: Standard
```

### Service Account
```
이름: github-actions-deploy
역할 (3개):
  - Cloud Run 관리자
  - Storage 관리자
  - Cloud Build 편집자
```

---

## 🎯 GitHub 설정값

### 저장소 정보
```
Repository name: jeonghwa-library
Description: 정화의서재 - 어린이 동화 플랫폼
Visibility: Private
```

### GitHub Secrets (5개)

**복사해서 붙여넣기:**

#### Secret 1
```
Name: GCP_PROJECT_ID
Value: (GCP에서 생성한 프로젝트 ID)
```

#### Secret 2
```
Name: GCP_SA_KEY
Value: (다운로드한 JSON 파일 전체 내용)
```

#### Secret 3
```
Name: RAILS_MASTER_KEY
Value: 71dfcbdae82a7dbd6f483bc635a1b024
```

#### Secret 4
```
Name: CLOUDFLARE_API_TOKEN
Value: ge0s_pYVROWkOqzxWxIH34Pki_KmWYVbkfTwsE7q
```

#### Secret 5
```
Name: CLOUDFLARE_ZONE_ID
Value: 173b110305a65f8392f54ea55c116867
```

---

## 📝 완료 후 AI에게 전달할 정보

**모든 작업 완료 후 다음 형식으로 전달:**

```
배포 준비 완료!

GCP 프로젝트 ID: jeonghwa-prod
GCP 프로젝트 번호: 123456789012
GitHub Username: jeonghwa-library (또는 실제 username)
GitHub 저장소: jeonghwa-library

모든 설정 완료!
```

---

## ⚠️ 보안 주의

**절대 GitHub에 커밋하지 말 것:**
```
❌ config/master.key
❌ Service Account JSON 파일
❌ .env 파일
❌ config/google_service_account.json
```

**✅ 이미 .gitignore에 추가되어 있음**

---

**작성일:** 2025-10-23  
**참조 문서:** docs/USER_SETUP_CHECKLIST.md

**이 정보로 GCP/GitHub 설정을 완료하세요!** 🚀


