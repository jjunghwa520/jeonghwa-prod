# frozen_string_literal: true

# Secure Headers 설정
# 웹 보안 헤더를 자동으로 추가하여 XSS, Clickjacking 등 방어

SecureHeaders::Configuration.default do |config|
  # X-Frame-Options: iframe 삽입 방지
  config.x_frame_options = "DENY"
  
  # X-Content-Type-Options: MIME 타입 스니핑 방지
  config.x_content_type_options = "nosniff"
  
  # X-XSS-Protection: 레거시 브라우저 XSS 방어
  config.x_xss_protection = "1; mode=block"
  
  # X-Download-Options: IE에서 다운로드 파일 실행 방지
  config.x_download_options = "noopen"
  
  # X-Permitted-Cross-Domain-Policies: Flash/PDF 크로스 도메인 제한
  config.x_permitted_cross_domain_policies = "none"
  
  # Referrer-Policy: 리퍼러 정보 제한
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]
  
  # Content-Security-Policy (CSP)
  config.csp = {
    # 기본: 자신의 도메인만
    default_src: %w['self'],
    
    # 스크립트: 자신 + 인라인 + 신뢰 가능한 출처 (운영 최소 허용: unsafe-eval 제거)
    script_src: %w[
      'self'
      'unsafe-inline'
      https://cdn.jsdelivr.net
      https://www.googletagmanager.com
      https://js.tosspayments.com
    ],
    
    # 스타일: 자신 + 인라인 + 폰트/아이콘 CDN
    style_src: %w[
      'self'
      'unsafe-inline'
      https://fonts.googleapis.com
      https://cdn.jsdelivr.net
      https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/
    ],
    
    # 이미지: 자신 + data URI + HTTPS + blob
    img_src: %w[
      'self'
      data:
      https:
      blob:
      https://storage.googleapis.com
    ],
    
    # 폰트: 자신 + Google Fonts + jsDelivr 아이콘 폰트
    font_src: %w[
      'self'
      https://fonts.gstatic.com
      https://cdn.jsdelivr.net
      data:
    ],
    
    # AJAX/Fetch: 자신 + 필요한 API 도메인만
    connect_src: %w[
      'self'
      https://api.tosspayments.com
      https://generativelanguage.googleapis.com
      https://cdn.jsdelivr.net
    ],
    
    # iframe: 자신 + 토스페이먼츠
    frame_src: %w[
      'self'
      https://widget.tosspayments.com
    ],
    
    # 미디어: 자신 + blob (HLS)
    media_src: %w[
      'self'
      blob:
      https://storage.googleapis.com
    ],
    
    # object/embed: 차단
    object_src: %w['none'],
    
    # base 태그 제한
    base_uri: %w['self'],
    
    # 폼 제출: 자신만
    form_action: %w['self'],
    
    # 위반 리포트 (선택)
    # report_uri: %w[https://your-csp-report-endpoint.com/report]
  }
  
  # HTTP Strict Transport Security (HSTS)
  # HTTPS 강제 (프로덕션만)
  if Rails.env.production?
    config.hsts = "max-age=31536000; includeSubDomains; preload"
  else
    config.hsts = SecureHeaders::OPT_OUT
  end

  # 환경별 CSP 미세 조정
  if Rails.env.development?
    # 개발: 폰트/아이콘/웹소켓 허용 (핫리로드 등)
    config.csp[:font_src] = %w['self' https://fonts.gstatic.com https://cdn.jsdelivr.net data:]
    config.csp[:connect_src] |= %w[https://cdn.jsdelivr.net ws://localhost:3000 wss://localhost:3000]
  else
    # 운영: 불필요한 개발용 출처 제거 (특히 ws://)
    config.csp[:connect_src] = (Array(config.csp[:connect_src]) - %w[ws://localhost:3000 wss://localhost:3000]).uniq
  end
  
  # Expect-CT: Certificate Transparency
  # config.expect_ct = "max-age=86400, enforce"
  
  # Clear-Site-Data: 로그아웃 시 데이터 삭제
  # config.clear_site_data = %w[cache cookies storage]
end

# 특정 컨트롤러/액션에 대한 오버라이드 예시
# SecureHeaders::Configuration.override(:allow_iframes) do |config|
#   config.x_frame_options = "ALLOWALL"
# end



