#!/bin/bash

echo "🚀 AI 양방향 브릿지 시작..."

# 프로젝트 디렉토리
PROJECT_DIR="/Users/l2dogyu/KICDA/ruby/kicda-jh"
cd "$PROJECT_DIR"

# 브릿지 디렉토리 생성
mkdir -p .ai-bridge/{tasks,results,reviews,logs,completed}

# Ruby 브릿지 데몬 시작
echo "📡 Ruby Bridge Daemon 시작..."
ruby ai-bridge/bidirectional_bridge.rb daemon &
RUBY_PID=$!

# 상태 확인
sleep 2
if kill -0 $RUBY_PID 2>/dev/null; then
    echo "✅ Ruby Bridge 실행 중 (PID: $RUBY_PID)"
else
    echo "❌ Ruby Bridge 시작 실패"
    exit 1
fi

echo ""
echo "🌉 AI Bridge가 실행 중입니다!"
echo ""
echo "사용 방법:"
echo "  1. Cursor AI에서: 작업 지시"
echo "  2. Claude Desktop에서: 자동 실행 및 검토 요청"
echo "  3. 양방향 피드백 루프 자동 진행"
echo ""
echo "중지하려면: kill $RUBY_PID"
echo ""
echo "로그 확인: tail -f .ai-bridge/logs/bridge.log"

# PID 파일 저장
echo $RUBY_PID > .ai-bridge/bridge.pid

# 로그 모니터링
tail -f .ai-bridge/logs/bridge.log
