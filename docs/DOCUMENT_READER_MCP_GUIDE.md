# Document Reader MCP 서버 사용 가이드

## 개요

Cursor에서 PDF 및 HWP(한글) 파일을 읽을 수 있도록 하는 MCP 서버입니다.

## 설치 완료 내역

✅ 필요한 패키지 설치 완료:
- `pdf-parse`: PDF 파일 파싱
- `node-hwp`: HWP 파일 파싱
- `@modelcontextprotocol/sdk`: MCP 서버 SDK

✅ MCP 서버 파일 생성:
- 위치: `/Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers/document-reader-mcp.js`

✅ Cursor 설정 파일 생성:
- 위치: `/Users/l2dogyu/KICDA/ruby/kicda-jh/.cursor/mcp.json`

## 사용 방법

### 1. Cursor 재시작

MCP 서버가 활성화되도록 **Cursor를 완전히 종료하고 다시 시작**해주세요.

### 2. 사용 가능한 도구

Cursor에서 다음 도구들을 사용할 수 있습니다:

#### `read_pdf`
PDF 파일을 읽어서 텍스트 내용을 추출합니다.

**파라미터:**
- `file_path`: 읽을 PDF 파일의 절대 경로

**예시:**
```
/path/to/document.pdf 파일을 읽어줘
```

**출력 형식:**
```json
{
  "title": "문서 제목",
  "author": "저자",
  "pages": 10,
  "text": "전체 텍스트 내용..."
}
```

#### `read_hwp`
HWP(한글) 파일을 읽어서 텍스트 내용을 추출합니다.

**파라미터:**
- `file_path`: 읽을 HWP 파일의 절대 경로

**예시:**
```
/path/to/document.hwp 파일을 읽어줘
```

**출력 형식:**
```json
{
  "filename": "document.hwp",
  "sections": 3,
  "text": "=== Section 1 ===\n내용...\n=== Section 2 ===\n내용..."
}
```

### 3. Cursor에서 사용하기

Cursor 채팅에서 자연어로 요청하면 됩니다:

```
/Users/l2dogyu/Documents/report.pdf 파일을 읽고 요약해줘
```

```
~/Desktop/proposal.hwp 파일의 내용을 분석해줘
```

## 지원 파일 형식

### PDF (.pdf)
- ✅ 텍스트 추출
- ✅ 메타데이터 (제목, 저자, 페이지 수)
- ❌ 이미지 추출 (현재 미지원)
- ❌ 표 구조 인식 (현재 미지원)

### HWP (.hwp)
- ✅ 텍스트 추출
- ✅ 섹션 구분
- ❌ 복잡한 레이아웃 (현재 제한적 지원)
- ❌ 이미지 추출 (현재 미지원)

## 문제 해결

### MCP 서버가 인식되지 않을 때

1. Cursor를 완전히 종료하고 다시 시작
2. `.cursor/mcp.json` 파일 확인
3. MCP 서버 파일 실행 권한 확인:
   ```bash
   chmod +x /Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers/document-reader-mcp.js
   ```

### PDF 읽기 오류

- 암호화된 PDF는 지원하지 않습니다
- 스캔된 이미지만 있는 PDF는 OCR이 필요합니다 (현재 미지원)

### HWP 읽기 오류

- 최신 HWP 파일 형식(.hwpx)은 제한적으로 지원될 수 있습니다
- 복잡한 레이아웃의 경우 텍스트 추출이 완벽하지 않을 수 있습니다

## 수동 테스트

MCP 서버를 직접 테스트하려면:

```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers
node document-reader-mcp.js
```

서버가 시작되면 "Document Reader MCP Server running on stdio" 메시지가 표시됩니다.

## 향후 개선 계획

- [ ] DOCX (MS Word) 파일 지원
- [ ] 이미지가 포함된 문서 처리
- [ ] 표 구조 인식 및 추출
- [ ] OCR 기능 추가 (이미지 PDF 처리)
- [ ] 더 나은 HWP 레이아웃 처리

## 기술 스택

- **Node.js**: MCP 서버 런타임
- **@modelcontextprotocol/sdk**: MCP 프로토콜 구현
- **pdf-parse**: PDF 파싱 라이브러리
- **node-hwp**: HWP 파싱 라이브러리

## 관련 파일

- MCP 서버: `/Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers/document-reader-mcp.js`
- 설정 파일: `/Users/l2dogyu/KICDA/ruby/kicda-jh/.cursor/mcp.json`
- 패키지 관리: `/Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers/package.json`

