# 2025-10-13 인수인계 (대용량 테스트 · 관리자페이지 구축 · 브라우저 검증)

## 요약
- 목업 자산 주입 완료: `public/ebooks/1001/pages/page_001..150.jpg` + 캡션 150개, 60분 MP4, HLS(m3u8/ts), 자막(ko/en).
- 관리자 `/admin` 구축: Dashboard, Courses(CRUD), Uploads(파일→public 경로 매핑), Reviews(active 토글/삭제), Users(권한 변경).
- 리뷰 비활성화 스키마: `reviews.active:boolean{default:true}` + 프론트는 `active_only`만 노출.
- 브라우저 스모크: 리더/플레이어/업로드/리뷰/사용자 확인. HLS는 hls.js 부착(blob src) 확인.
- 서버 재시작 없이 동작(정적 자산/자동 리로드).

---

## 생성/변경 요약
- 데이터/자산
  - 전자책: `public/ebooks/1001/pages/page_001.jpg` .. `page_150.jpg`
  - 캡션: `public/ebooks/1001/pages/page_001.txt` .. `page_150.txt`
  - MP4: `public/videos/1001/main.mp4` (60분)
  - 자막: `public/videos/1001/ko.vtt`, `public/videos/1001/en.vtt`
  - HLS: `public/videos/1002/index.m3u8`, `public/videos/1002/segment_*.ts`
- 코드/라우트
  - `config/routes.rb`: `namespace :admin` 추가
  - `app/controllers/application_controller.rb`: `require_admin`
  - `app/controllers/admin/*`: `Base, Dashboard, Courses, Uploads, Reviews, Users`
  - `app/views/admin/**/*`: MVP 화면
  - `db/migrate/20251013120000_add_active_to_reviews.rb`
  - `app/models/review.rb`: `scope :active_only`
  - `app/controllers/courses_controller.rb#show`: 활성 리뷰만 노출

---

## 계정/콘텐츠
- 관리자: `admin@example.com` / `password123`
- 테스트 코스: `id=1001`, `status=published`
  - `video_url`: `/videos/1002/index.m3u8` (HLS) ← 필요시 `/videos/1001/main.mp4`
  - `ebook_pages_root`: `/ebooks/1001/pages`

---

## 주요 경로
- 관리자: `/admin`, `/admin/courses`, `/admin/courses/1001`, `/admin/uploads/new`, `/admin/reviews`, `/admin/users`
- 프론트: `/courses/1001`, `/courses/1001/read`, `/courses/1001/watch`

---

## 리더 체크리스트
- 빠른 넘김/랜덤 점프, ±2 프리로드 유지
- 캡션/TTS 버튼, 전환 시 TTS cancel
- 미수강 10% 프리뷰 게이트
- 이어보기: `localStorage` `reader:1001:page`

## 플레이어 체크리스트
- HLS 부착: `window.Hls===true`, `video.currentSrc`가 `blob:`
- 자막 트랙 자동 탐색(ko/en)
- 미수강 10% 프리뷰 게이트
- 이어보기: `localStorage` `watch:1001:position`

---

## 업로드 매핑
- `/admin/uploads/new` → kind별 저장 위치
  - `ebook_images`/`captions`: `/ebooks/:id/pages/`
  - `video`/`subtitle`/`hls`: `/videos/:id/`

---

## 장시간 시나리오(내일)
- 리더(15분+): 빠른 넘김/랜덤 점프/TTS 반복, 콘솔 에러 0, 1440·390 모두 기록
- 플레이어(60~120분): 이어보기 ±1s, 자막 토글·탐색·전체화면, 프리뷰 게이트, 콘솔 에러 0

---

## 메모/워닝
- `application.css preload` 경고 노출 시에만 조정(선택): preload 제거 또는 `as="style" onload` 패턴.

---

## 롤백
- 자산 정리: `public/ebooks/1001/`, `public/videos/1001/`, `public/videos/1002/`
- 코스 `video_url` 복구, 리뷰 `active` 토글로 노출 제어

---

## 내일 작업 실행 프롬프트
```text
목표: 1440/390에서 리더·플레이어 장시간 안정성 검증, 어드민-프론트 반영 확인, 콘솔 에러 0 유지.
전제: 서버 재시작 금지. 테스트 코스(id=1001)와 자산 사용.

1) 리더 1440
- /courses/1001/read → 빠른 넘김 50회, 랜덤 썸네일 점프 30회
- TTS 버튼 20회 반복, 전환 시 캡션/음성 싱크 확인
- ±2 프리로드 유지 관찰, 콘솔 에러 0
- localStorage(`reader:1001:page`) 복원 확인 후 새로고침

2) 플레이어 1440(HLS)
- /courses/1001/watch → window.Hls===true, video.currentSrc=blob:* 확인
- 자막(ko/en) 토글, 10초 탐색, 전체화면/속도 변경, 프리뷰 게이트 재현
- 5~7분 재생 → 새로고침 → `watch:1001:position` 복원 ±1s
- 콘솔/네트워크 오류 0

3) 관리자 반영
- /admin/uploads/new: page_010.txt 교체 업로드 → 리더 반영 확인
- /admin/reviews: 리뷰 active 토글/삭제 → 상세 반영
- /admin/users: 임의 사용자 권한 instructor/admin 전환 확인

4) 모바일 390
- 390×844로 리더/플레이어 UI 겹침/오버플로우 여부 점검
- 축약 체크리스트 반복, 콘솔 에러 0

5) 결과 보고
- 지연/프리즈/메모리 상승 발견 시: 타임스탬프·재현절차·스크린샷
- 이상 없으면 "AC 충족" 결론 + 필요 스크린샷 링크
```
