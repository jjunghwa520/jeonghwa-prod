# 📄 PDF & HWP 파일 읽기 설정 완료

Cursor에서 PDF와 HWP 파일을 읽을 수 있도록 MCP 서버가 설정되었습니다.

## 🚀 빠른 시작

### 1단계: Cursor 재시작
**중요**: Cursor를 **완전히 종료**하고 다시 시작해주세요.

### 2단계: 파일 읽기
Cursor 채팅에서 자연어로 요청하세요:

```
/Users/l2dogyu/Documents/report.pdf 파일을 읽어줘
```

```
~/Desktop/document.hwp 파일의 내용을 요약해줘
```

## ✅ 설치 완료 내역

- ✅ PDF 파서 (pdf-parse)
- ✅ HWP 파서 (node-hwp)
- ✅ MCP 서버 (document-reader-mcp.js)
- ✅ Cursor 설정 (.cursor/mcp.json)

## 📖 지원 기능

### PDF 파일
- 텍스트 추출
- 메타데이터 (제목, 저자, 페이지 수)
- 다중 페이지 문서

### HWP 파일
- 텍스트 추출
- 섹션별 구분
- 한글 문서 처리

## 🔧 테스트

설정이 제대로 되었는지 확인:

```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers
node test-document-reader.js
```

## 📚 상세 문서

더 자세한 정보는 [DOCUMENT_READER_MCP_GUIDE.md](docs/DOCUMENT_READER_MCP_GUIDE.md)를 참고하세요.

## 🐛 문제 해결

MCP 서버가 인식되지 않으면:
1. Cursor를 완전히 종료 (Cmd+Q)
2. 다시 시작
3. 여전히 문제가 있다면 테스트 스크립트 실행

## 📁 관련 파일

- MCP 서버: `mcp-servers/document-reader-mcp.js`
- 설정: `.cursor/mcp.json`
- 테스트: `mcp-servers/test-document-reader.js`
- 가이드: `docs/DOCUMENT_READER_MCP_GUIDE.md`

