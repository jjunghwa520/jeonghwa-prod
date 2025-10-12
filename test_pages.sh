#!/bin/bash

# 페이지 접속 테스트 스크립트

echo "🧪 모든 페이지 접속 테스트를 시작합니다..."
echo "=================================="

# 테스트할 페이지들
declare -A pages=(
    ["홈페이지"]="/"
    ["강의 목록"]="/courses"
    ["강의 검색"]="/courses/search"
    ["로그인"]="/login"
    ["회원가입"]="/signup"
    ["장바구니 (로그인 필요)"]="/cart_items"
    ["첫 번째 강의 상세"]="/courses/1"
    ["첫 번째 사용자 프로필"]="/users/1"
)

BASE_URL="http://localhost:3000"

for name in "${!pages[@]}"; do
    path="${pages[$name]}"
    echo -n "📄 $name ($path): "
    
    response=$(/usr/bin/curl -s -I "$BASE_URL$path" | /usr/bin/head -1)
    status_code=$(echo "$response" | /usr/bin/cut -d' ' -f2)
    
    case $status_code in
        200)
            echo "✅ 정상 (200 OK)"
            ;;
        302)
            echo "🔄 리다이렉트 (302 Found) - 로그인 필요"
            ;;
        404)
            echo "❌ 페이지 없음 (404 Not Found)"
            ;;
        500)
            echo "🔥 서버 오류 (500 Internal Server Error)"
            ;;
        *)
            echo "⚠️ 알 수 없음 ($status_code)"
            ;;
    esac
done

echo "=================================="
echo "✨ 테스트 완료!"

