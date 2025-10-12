#!/bin/bash

# 프로덕션 서버 시작 스크립트

echo "🚀 프로덕션 서버를 시작합니다..."

# 환경 변수 설정
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=true

# 포트 설정 (기본 3000, 원하면 변경 가능)
PORT=${PORT:-3000}

echo "📦 데이터베이스 마이그레이션 확인..."
bin/rails db:migrate

echo "🎨 자산 컴파일 확인..."
if [ ! -d "public/assets" ] || [ -z "$(ls -A public/assets)" ]; then
  echo "자산을 컴파일합니다..."
  bin/rails assets:precompile
fi

echo "✅ 서버를 포트 $PORT에서 시작합니다..."
echo "🌐 브라우저에서 http://localhost:$PORT 로 접속하세요"
echo ""
echo "📧 테스트 계정:"
echo "  관리자: admin@inflearn.com / password123"
echo "  강사: instructor1@inflearn.com / password123"
echo "  학생: student1@inflearn.com / password123"
echo ""
echo "종료하려면 Ctrl+C를 누르세요"

# Puma 서버 시작
bin/rails server -p $PORT

