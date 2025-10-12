# 삭제된 작업 파일들 백업 (참고용)

## 삭제 사유
이 파일들은 개발 과정에서 생성된 실험적/임시적 파일들로, 현재 완성된 시스템에서는 사용하지 않습니다.
혼동과 중복 적용을 방지하기 위해 삭제되었으며, 필요시 참고용으로만 사용하세요.

## 삭제된 파일 목록

### 1. teen_vertex_images.rake
- **목적**: 청소년 콘텐츠 전용 Vertex AI 이미지 생성
- **삭제 사유**: title_specific_vertex.rake로 통합됨
- **대체 방법**: rake title_specific_vertex:generate 사용

### 2. test_vertex_simple.rake  
- **목적**: Vertex AI 연결 테스트
- **삭제 사유**: 테스트 완료, 더 이상 불필요
- **대체 방법**: 필요시 직접 VertexImageGenerator 클래스 사용

### 3. vertex_images.rake
- **목적**: 초기 Vertex AI 이미지 생성 실험
- **삭제 사유**: title_specific_vertex.rake로 발전됨
- **대체 방법**: rake title_specific_vertex:generate 사용

### 4. debug_vertex_policy.rake
- **목적**: Vertex AI 정책 위반 디버깅
- **삭제 사유**: 정책 위반 문제 해결 완료
- **대체 방법**: 필요시 안전한 프롬프트 사용

## ⚠️ 중요 주의사항
- **이 파일들을 재생성하지 마세요**
- **현재 시스템은 title_specific_vertex.rake 하나만 사용합니다**
- **문제 발생 시 BACKUP_STATUS_2025_09_11.md 참조하세요**

## 현재 사용 중인 유일한 태스크
```bash
rake title_specific_vertex:generate  # 모든 썸네일 생성
```

이 하나의 태스크가 모든 콘텐츠(전자동화책, 구연동화, 교육, 청소년)의 썸네일을 생성합니다.

### 5. kids_thumbnails.rake
- **목적**: 키즈 친화적 썸네일 생성 실험
- **삭제 사유**: title_specific_vertex.rake로 통합됨

### 6. diverse_thumbnails.rake  
- **목적**: 다양한 스타일 썸네일 생성 실험
- **삭제 사유**: title_specific_vertex.rake로 통합됨

### 7. generate_cultural_svgs.rake
- **목적**: 문화적 SVG 이미지 생성
- **삭제 사유**: SVG 방식 완전 폐기, Vertex AI만 사용

### 8. cultural_thumbnails.rake
- **목적**: 문화적 테마 썸네일 생성
- **삭제 사유**: title_specific_vertex.rake로 통합됨

### 9. title_specific_thumbnails.rake
- **목적**: 제목별 썸네일 생성 (초기 버전)
- **삭제 사유**: title_specific_vertex.rake로 발전됨

### 10. storybook_thumbnails.rake
- **목적**: 동화책 스타일 썸네일 생성
- **삭제 사유**: title_specific_vertex.rake로 통합됨

### 11. generate_thumbnails.rake
- **목적**: 일반 썸네일 생성
- **삭제 사유**: title_specific_vertex.rake로 통합됨

## 삭제된 이미지 디렉토리들

### app/assets/images/generated/ 하위 디렉토리들
- **abstract/**: 추상적 이미지들 (사용 중단)
- **title_specific/**: 초기 제목별 이미지들 (title_specific_vertex로 대체)
- **diverse_styles/**: 다양한 스타일 실험 이미지들
- **storybook/**: 동화책 스타일 실험 이미지들  
- **friendly/**: 친화적 스타일 실험 이미지들
- **storybook_ai/**: AI 동화책 스타일 실험 이미지들
- **courses/**: 코스별 실험 이미지들
- **age_groups/**: 연령별 실험 이미지들
- **kids/**: 키즈 친화적 실험 이미지들
- **thumbnails/**: 일반 썸네일 실험 이미지들
- **cultural/**: 문화적 테마 실험 이미지들

### 유지되는 유일한 디렉토리
- **title_specific_vertex/**: 현재 사용 중인 Vertex AI 생성 이미지들 (40개)
