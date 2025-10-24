# frozen_string_literal: true

# 세션 스토어 보안 설정

Rails.application.config.session_store :cookie_store,
  # 세션 쿠키 이름
  key: '_jeonghwa_session',
  
  # 세션 만료 시간 (30분)
  expire_after: 30.minutes,
  
  # HttpOnly: JavaScript 접근 차단
  httponly: true,
  
  # Secure: HTTPS에서만 전송 (프로덕션)
  secure: Rails.env.production?,
  
  # SameSite: CSRF 방어
  same_site: :lax
  
  # 도메인 설정 (프로덕션)
  # domain: '.jeonghwa.com'



