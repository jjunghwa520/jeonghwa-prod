# ⚡ 빠른 시작 가이드 (2025-10-20)

## 🎯 오늘의 목표

**AI 콘텐츠 생성기 완성하기**
1. Vertex AI 실제 구현 (1-2시간)
2. 브라우저 테스트 (30분)
3. nano-meta 점검 완료 (2-3시간)

---

## 📂 핵심 파일

### 수정 필요 (우선순위 순)
1. `app/jobs/generate_ebook_pages_with_stories_job.rb` ⭐⭐⭐
   - 줄 52: `generate_image_with_vertex_ai` 메서드 구현 필요
   - 참고: `lib/tasks/title_specific_vertex.rake` (이미 작동하는 코드)

2. `app/views/admin/content_generator/index.html.erb`
   - 완성됨, 테스트 필요

3. `app/controllers/admin/content_generator_controller.rb`
   - 완성됨, 테스트 필요

### 참고용
- `lib/tasks/title_specific_vertex.rake` - Vertex AI 호출 예제
- `docs/handover_2025-10-19.md` - 상세 인수인계
- `docs/WORK_SUMMARY_2025-10-19.md` - 작업 요약

---

## 🚀 1단계: Vertex AI 구현 (60분)

### 코드 복사/수정
`app/jobs/generate_ebook_pages_with_stories_job.rb` 파일 열기:

```ruby
# 줄 52부터 수정
def generate_image_with_vertex_ai(prompt, resolution)
  require 'google/cloud/ai_platform/v1'
  require 'base64'
  
  project_id = 'inflearn-clone-443109'
  location = 'us-central1'
  endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/imagegeneration@006"
  
  # 클라이언트 생성
  client = Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
    config.endpoint = "#{location}-aiplatform.googleapis.com"
  end
  
  # 해상도 파싱
  width, height = resolution.split('x').map(&:to_i)
  aspect_ratio = "#{width}:#{height}"
  
  # 요청 구성
  instance = { prompt: prompt }
  parameters = {
    sampleCount: 1,
    aspectRatio: aspect_ratio,
    safetyFilterLevel: "block_some",
    personGeneration: "allow_adult"
  }
  
  # API 호출
  Rails.logger.info "Vertex AI 호출: #{prompt[0..100]}..."
  response = client.predict(
    endpoint: endpoint,
    instances: [instance],
    parameters: parameters
  )
  
  # 이미지 데이터 추출
  prediction = response.predictions.first
  image_data = Base64.decode64(prediction['bytesBase64Encoded'])
  
  Rails.logger.info "이미지 생성 성공 (#{image_data.bytesize} bytes)"
  image_data
  
rescue Google::Cloud::Error => e
  Rails.logger.error "Vertex AI 오류: #{e.message}"
  raise "AI 이미지 생성 실패: #{e.message}"
rescue => e
  Rails.logger.error "예상치 못한 오류: #{e.class} - #{e.message}"
  raise
end
```

### 저장 후 확인
```bash
# 서버 재시작 (백그라운드 잡 리로드)
# (사용자 요청에 따라 재시작 안 함 - 코드 변경 시 자동 리로드)
```

---

## 🧪 2단계: 브라우저 테스트 (30분)

### 서버 확인
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
# 서버가 이미 실행 중이라고 가정
```

### 테스트 시나리오

#### 테스트 1: 신규 생성 (간단)
1. 브라우저: `http://localhost:3000/admin/content_generator`
2. "신규 생성" 탭
3. 코스 선택: "🦁 용감한 사자왕의 모험 (ID: 1)"
4. 페이지 1 입력:
   ```
   용감한 사자왕이 숲 속을 걸어갑니다. 햇살이 나뭇잎 사이로 비춥니다.
   ```
5. "🎨 AI 이미지 생성 시작 (1페이지)" 클릭
6. 확인 다이얼로그 → 확인
7. Job 실행 확인:
   ```bash
   tail -f log/development.log | grep "GenerateEbookPagesWithStoriesJob"
   ```
8. 파일 생성 확인:
   ```bash
   ls -la public/ebooks/1/pages/
   cat public/ebooks/1/pages/page_001.txt
   ```

#### 테스트 2: 여러 페이지 생성
1. "➕ 페이지 추가" 3번 클릭 (총 4페이지)
2. 각 페이지에 스토리 입력
3. 생성 시작
4. 4개 파일 생성 확인

#### 테스트 3: AI 자동 스토리
1. 코스 선택
2. "🤖 AI 자동 스토리 생성" 클릭
3. 페이지 수 입력: 5
4. 자동 생성된 스토리 확인
5. 수정 후 생성

#### 테스트 4: 재생성 (기존 관리 탭)
1. "기존 관리" 탭
2. "🦁 용감한 사자왕의 모험" → "🎨 재생성" 클릭
3. 확인 다이얼로그
4. 백업 폴더 생성 확인:
   ```bash
   ls -la public/ebooks/1/
   ```

---

## 🐛 3단계: 예상 오류 및 해결

### 오류 1: "Vertex AI 연동 구현 필요"
**원인**: 아직 구현 안 됨  
**해결**: 위 1단계 코드 적용

### 오류 2: "Google::Cloud::Error"
**원인**: 인증 실패  
**해결**:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/Users/l2dogyu/KICDA/ruby/kicda-jh/config/google_service_account.json"
```

### 오류 3: Job이 실행 안 됨
**원인**: Solid Queue 미실행  
**해결**:
```bash
# 별도 터미널에서
bin/jobs
```

### 오류 4: 이미지 저장 실패
**원인**: 폴더 권한  
**해결**:
```bash
chmod -R 755 public/ebooks
```

---

## 📊 4단계: 결과 확인

### 성공 기준
- ✅ Job 실행 완료 (로그에 "전체 페이지 생성 완료!")
- ✅ 이미지 파일 생성 (`page_001.jpg` ~ `page_00N.jpg`)
- ✅ 캡션 파일 생성 (`page_001.txt` ~ `page_00N.txt`)
- ✅ 리더에서 이미지 표시됨 (`/courses/1/read`)
- ✅ 재생성 시 백업 폴더 생성됨

### 확인 명령어
```bash
# 생성된 파일 수 확인
ls public/ebooks/1/pages/*.jpg | wc -l

# 가장 최근 파일
ls -lt public/ebooks/1/pages/ | head -5

# 로그 확인
tail -100 log/development.log
```

---

## 🎯 5단계: nano-meta 점검

### 체크리스트
- [ ] 신규 등록 → 저장 → 업로드 (end-to-end)
- [ ] 작가 즉석 등록 → 모달 → AJAX → Select 업데이트
- [ ] 파일 업로드 → 진행률 → 성공 알림
- [ ] 파일 삭제 → 확인 다이얼로그 → 실제 삭제
- [ ] 키보드 단축키 (Cmd+N, Cmd+F, Cmd+A)
- [ ] 데이터 손실 방지 (뒤로가기, 새로고침)
- [ ] 임시저장 복구
- [ ] 모바일 반응형 (375px)

### 테스트 파일
`docs/test_manual_checklist.md` 참고

---

## 📞 도움말

### 로그 보기
```bash
# 전체 로그
tail -f log/development.log

# Job만
tail -f log/development.log | grep "Job"

# 에러만
tail -f log/development.log | grep "ERROR"
```

### Rails 콘솔 디버깅
```bash
rails c
> Course.find(1).title
> Dir.glob("public/ebooks/1/pages/*.jpg").count
```

### 서버 상태 확인
```bash
ps aux | grep rails
ps aux | grep jobs
```

---

## 🎉 완료 후

1. 스크린샷 저장 (AI 생성기 완성 화면)
2. 생성된 샘플 이미지 확인
3. `docs/WORK_SUMMARY_2025-10-20.md` 작성
4. Git commit (선택사항)

---

**예상 소요 시간**: 3-4시간  
**난이도**: 중  
**막힐 경우**: `docs/handover_2025-10-19.md` 참고  

**화이팅! 🚀**

