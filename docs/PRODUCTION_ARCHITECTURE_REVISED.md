# 수정된 프로덕션 아키텍처 - 대용량 콘텐츠 대응

**작성일:** 2025-10-23  
**문제:** 현재 1.5GB + 지속적인 콘텐츠 증가  
**해결:** 클라우드 스토리지 분리 아키텍처

---

## 🚨 현재 상황 분석

### 콘텐츠 현황
```
현재 용량:
- public 폴더: 1.5GB
- 이미지 파일: 721개
- 평균 이미지 크기: 4-6MB (Vertex AI 생성)
- 큰 스크린샷: 6MB

예상 증가:
- 월 20개 새 콘텐츠 추가 시
- 20개 × 4MB = 80MB/월
- 1년 후: 1.5GB + 960MB = 2.5GB
- 2년 후: 3.5GB+
```

### 기존 추천의 문제점

❌ **Vultr $6/월 (1GB RAM, 25GB SSD)**
```
문제:
1. 25GB SSD - 현재 1.5GB로 이미 6% 사용
2. 성장 시 빠르게 용량 부족
3. 백업 고려하면 더 부족
4. 이미지 최적화 없으면 1년 안에 가득 참
```

---

## 🏆 최적 솔루션: 하이브리드 아키텍처

### 아키텍처 개요

```
┌─────────────────┐
│   사용자        │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Cloudflare CDN │ ← 캐싱, 빠른 전송
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ↓         ↓
┌─────┐   ┌──────────────┐
│ VPS │   │ Cloud Storage│
│Rails│   │ (이미지/비디오)│
│ App │   └──────────────┘
└─────┘
 2GB     무제한 확장 가능
```

### 구성 요소

1. **VPS (앱 서버)**
   - Rails 앱만 실행
   - 데이터베이스 (SQLite)
   - 작은 정적 파일만 (CSS, JS)
   - **필요 사양:** 2GB RAM, 40GB SSD

2. **클라우드 스토리지**
   - 모든 이미지/비디오
   - 무제한 확장
   - 사용한 만큼만 과금

3. **CDN (Cloudflare)**
   - 무료 CDN
   - 전 세계 빠른 전송
   - 대역폭 절약

---

## 💰 비용 비교

### 옵션 A: VPS만 사용 (비추천)

```yaml
Vultr Seoul (4GB RAM, 80GB SSD): $12/월
백업: $2.40/월
총: $14.40/월 (₩19,440)

문제:
- 여전히 스토리지 제한
- 확장성 낮음
- 트래픽 많으면 느림
```

### 옵션 B: 하이브리드 (강력 추천) 🏆

```yaml
VPS (2GB RAM, 40GB SSD):
  Vultr Seoul: $12/월 (₩16,200)

클라우드 스토리지:
  옵션 1 - Cloudflare R2 (추천):
    첫 10GB: 무료
    이후: $0.015/GB/월
    현재 1.5GB: 무료
    10GB까지 성장: 무료
    트래픽: 무료! ⭐
  
  옵션 2 - Google Cloud Storage:
    $0.020/GB/월
    현재 1.5GB: $0.03/월
    트래픽(한국): $0.12/GB
  
  옵션 3 - AWS S3:
    $0.023/GB/월
    현재 1.5GB: $0.03/월
    트래픽: $0.09/GB

도메인:
  Cloudflare: $9.77/년 (₩810/월)

총 (Cloudflare R2 사용):
  초기: $12.81/월 (₩17,300)
  10GB까지: $12.81/월
  100GB 성장: $14.16/월 (₩19,100)
  
총 (Google Cloud Storage):
  초기: $12.84/월 (₩17,300)
  10GB 성장: $13.01/월
  트래픽 500GB/월: $73/월
```

### 옵션 C: 풀 클라우드 (GCP)

```yaml
Cloud Run (앱): $15-30/월
Cloud Storage: $0.30/월 (15GB)
Cloud SQL: $10-25/월
트래픽: $5-20/월
총: $30-75/월 (₩40,500-101,250)

장점: 완전 관리형, 자동 스케일
단점: 비용 높음
```

---

## 🎯 최종 추천: VPS + Cloudflare R2

### 왜 Cloudflare R2인가?

```yaml
장점:
  ✅ 첫 10GB 무료
  ✅ 트래픽 완전 무료 (egress free)
  ✅ Cloudflare CDN 자동 연동
  ✅ S3 호환 API
  ✅ 한국 사용자에게 빠름

비용:
  10GB까지: 무료
  100GB: $1.35/월 (₩1,800)
  1TB: $15/월 (₩20,000)
  
트래픽:
  무제한 무료! ⭐⭐⭐
```

### 총 비용 예상

```
초기 (현재 1.5GB):
  VPS: ₩16,200
  R2: ₩0 (무료)
  도메인: ₩810
  총: ₩17,010/월

6개월 후 (5GB):
  VPS: ₩16,200
  R2: ₩0 (무료)
  도메인: ₩810
  총: ₩17,010/월

1년 후 (10GB):
  VPS: ₩16,200
  R2: ₩0 (무료)
  도메인: ₩810
  총: ₩17,010/월

2년 후 (30GB):
  VPS: ₩16,200
  R2: ₩405 ($0.30)
  도메인: ₩810
  총: ₩17,415/월

5년 후 (100GB):
  VPS: ₩16,200
  R2: ₩1,820 ($1.35)
  도메인: ₩810
  총: ₩18,830/월
```

---

## 🛠️ 구현 방법

### Step 1: VPS 선택

**추천: Vultr Seoul (2GB RAM)**

```yaml
사양:
  CPU: 1 vCore
  RAM: 2GB
  SSD: 55GB
  트래픽: 2TB/월
  가격: $12/월

링크: https://www.vultr.com
위치: Seoul, South Korea 선택
```

### Step 2: Cloudflare R2 설정

**가입 및 버킷 생성 (15분)**

```bash
1. Cloudflare 대시보드 로그인
   https://dash.cloudflare.com

2. R2 → Create bucket
   - Name: jeonghwa-assets
   - Location: Automatic (가장 가까운 위치 자동)

3. API Token 생성
   - R2 → Manage R2 API Tokens
   - Create API Token
   - Permissions: Object Read & Write
   - 토큰 복사 (다시 볼 수 없음!)

4. 버킷 도메인 설정 (선택)
   - Custom Domains → Add
   - assets.jeonghwa-library.com
```

### Step 3: Rails Active Storage 설정

**config/storage.yml 수정**

```yaml
# config/storage.yml

# 로컬 개발
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

# 프로덕션: Cloudflare R2
cloudflare:
  service: S3
  access_key_id: <%= ENV['R2_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['R2_SECRET_ACCESS_KEY'] %>
  region: auto
  bucket: jeonghwa-assets
  endpoint: https://<account_id>.r2.cloudflarestorage.com
  public: true
```

**config/environments/production.rb**

```ruby
# Active Storage 설정
config.active_storage.service = :cloudflare
```

### Step 4: 기존 파일 마이그레이션

**로컬에서 실행 (한 번만)**

```bash
# 1. Rclone 설치 (파일 전송 도구)
brew install rclone

# 2. Rclone 설정
rclone config
# 선택: n (new remote)
# 이름: r2
# Storage: s3
# Provider: Cloudflare
# Access Key: [R2 Access Key]
# Secret Key: [R2 Secret Key]
# Endpoint: https://<account_id>.r2.cloudflarestorage.com

# 3. 파일 업로드
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# 이미지 파일만 업로드
rclone copy public/assets/generated/ r2:jeonghwa-assets/assets/generated/ \
  --progress \
  --transfers 10

# 완료 확인
rclone ls r2:jeonghwa-assets
```

### Step 5: Rails 코드 수정

**app/helpers/application_helper.rb**

```ruby
def asset_url(path)
  if Rails.env.production?
    # R2 CDN URL
    "https://assets.jeonghwa-library.com/#{path}"
  else
    # 로컬 개발
    asset_path(path)
  end
end
```

**뷰에서 사용**

```erb
<!-- Before -->
<%= image_tag "assets/generated/image.jpg" %>

<!-- After -->
<%= image_tag asset_url("assets/generated/image.jpg") %>
```

---

## 📊 성능 비교

### 시나리오: 사용자 1,000명, 월 100GB 트래픽

**옵션 A: VPS만**
```
VPS (4GB, 100GB): $24/월
백업: $4.80/월
총: $28.80/월

문제:
- 대역폭 제한 (4TB/월)
- 느린 응답 속도
- 서버 부하 높음
```

**옵션 B: VPS + Cloudflare R2 (추천)**
```
VPS (2GB): $12/월
R2 (20GB 저장): $0.15/월
R2 트래픽: $0 (무료!)
도메인: $0.81/월
총: $12.96/월

장점:
- 트래픽 무제한
- CDN으로 빠름
- 서버 부하 낮음
- 확장 용이
```

**옵션 C: GCP**
```
Cloud Run: $25/월
Cloud Storage (20GB): $0.40/월
트래픽 (100GB): $12/월
총: $37.40/월
```

---

## 🚀 마이그레이션 계획

### Phase 1: 초기 배포 (지금)

```
1. VPS (2GB) 구매 - $12/월
2. Cloudflare R2 설정 - 무료
3. 기존 파일 업로드
4. Rails 코드 수정
5. 배포

예상 시간: 3-4시간
총 비용: $12.81/월 (₩17,300)
```

### Phase 2: 이미지 최적화 (1주일 내)

```
1. ImageMagick 설치
2. 이미지 압축 (4-6MB → 500KB-1MB)
3. WebP 변환
4. 썸네일 자동 생성

예상 효과:
- 용량 70% 감소 (1.5GB → 450MB)
- 로딩 속도 3배 향상
- R2 비용 거의 무료 유지
```

### Phase 3: 비디오 대응 (향후)

```
비디오 추가 시:
- R2 또는 Bunny CDN
- HLS 스트리밍
- 자동 화질 변환

예상 추가 비용:
- 100GB 비디오: $1.50/월
- 트래픽: 무료 (R2)
```

---

## ✅ 최종 추천 구성

### 즉시 실행

```yaml
VPS:
  회사: Vultr
  위치: Seoul
  사양: 2GB RAM, 55GB SSD
  가격: $12/월

스토리지:
  서비스: Cloudflare R2
  용량: 10GB 무료
  트래픽: 무료
  가격: $0/월 (10GB까지)

도메인:
  등록: Cloudflare
  가격: $9.77/년

총 비용:
  초기: $12.81/월 (₩17,300)
  성장 후: $14-15/월 (₩19,000)
```

### 다음 단계

1. ✅ 이미지 최적화 (필수)
2. ✅ R2 설정 및 마이그레이션
3. ✅ CDN 활성화
4. 📅 성능 모니터링
5. 📅 비용 추적

---

## 🎓 이미지 최적화 스크립트

### 자동 최적화 Rake Task

```ruby
# lib/tasks/optimize_images.rake

namespace :images do
  desc "Optimize all images"
  task optimize: :environment do
    require 'mini_magick'
    
    Dir.glob("public/assets/generated/**/*.{jpg,jpeg,png}").each do |file|
      puts "Optimizing: #{file}"
      
      image = MiniMagick::Image.open(file)
      
      # 리사이즈 (최대 1920px)
      image.resize "1920x1920>" if image.width > 1920 || image.height > 1920
      
      # 품질 85%
      image.quality 85
      
      # 저장
      image.write file
      
      # WebP 변환
      webp_file = file.sub(/\.(jpg|jpeg|png)$/, '.webp')
      image.format 'webp'
      image.quality 85
      image.write webp_file
      
      puts "  Original: #{File.size(file) / 1024 / 1024}MB"
      puts "  WebP: #{File.size(webp_file) / 1024 / 1024}MB"
    end
    
    puts "Optimization complete!"
  end
end
```

**실행:**
```bash
bin/rails images:optimize
```

**예상 효과:**
```
Before:
- 721 images × 4MB = 2.88GB

After:
- 721 images × 500KB = 360MB
- 721 webp × 300KB = 216MB
총: 576MB (80% 감소!)
```

---

## 📞 문의 사항

### Cloudflare R2 관련
- 문서: https://developers.cloudflare.com/r2/
- 가격: https://developers.cloudflare.com/r2/pricing/

### VPS 관련
- Vultr: https://www.vultr.com/pricing/
- DigitalOcean: https://www.digitalocean.com/pricing/

---

**작성일:** 2025년 10월 23일  
**업데이트:** 배포 후 실제 비용 반영 예정

**핵심 요약:**
- VPS 2GB ($12/월) + Cloudflare R2 (무료~$2/월)
- 총 비용: 월 ₩17,000-19,000
- 무제한 확장 가능
- 빠른 CDN 속도
- 이미지 최적화로 비용 최소화

**다음 작업:**
1. 이 아키텍처로 배포 가이드 업데이트
2. R2 설정 가이드 작성
3. 이미지 최적화 자동화


