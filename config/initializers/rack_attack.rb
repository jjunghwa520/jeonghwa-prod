# frozen_string_literal: true

# Rack::Attack 보안 설정
# 무차별 대입 공격, API 남용 방지

class Rack::Attack
  ### 설정 ###
  
  # 캐시 스토어: 운영은 Redis, 개발/테스트는 메모리
  if Rails.env.production? && ENV['REDIS_URL'].present?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end
  
  ### Safelist (허용 목록) ###
  
  # 로컬호스트는 기본 허용하되, 보안상 중요한 엔드포인트(예: 로그인 POST)는 제외
  safelist('allow-localhost') do |req|
    next false if req.path == '/login' && req.post?
    (req.ip == '127.0.0.1' || req.ip == '::1')
  end
  
  ### Throttle (요청 제한) ###
  
  # 로그인 시도: ENV 기반 임계치 (기본: 15분 5회)
  login_limit = (ENV['RACK_ATTACK_LOGIN_LIMIT'] || 5).to_i
  login_period = (ENV['RACK_ATTACK_LOGIN_PERIOD_SECONDS'] || 15.minutes).to_i
  throttle('login/ip', limit: login_limit, period: login_period) do |req|
    req.ip if req.path == '/login' && req.post?
  end
  
  # 로그인 시도: 이메일당
  throttle('login/email', limit: login_limit, period: login_period) do |req|
    if req.path == '/login' && req.post?
      req.params['email'].to_s.downcase.presence
    end
  end
  
  # 회원가입: IP당 1시간에 3번
  throttle('signup/ip', limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/signup' && req.post?
  end
  
  # API 요청: ENV 기반 (기본: 1분 60회)
  api_limit = (ENV['RACK_ATTACK_API_LIMIT'] || 60).to_i
  api_period = (ENV['RACK_ATTACK_API_PERIOD_SECONDS'] || 1.minute).to_i
  throttle('api/ip', limit: api_limit, period: api_period) do |req|
    req.ip if req.path.start_with?('/api/')
  end
  
  # 결제 요청
  payment_limit = (ENV['RACK_ATTACK_PAYMENT_LIMIT'] || 5).to_i
  payment_period = (ENV['RACK_ATTACK_PAYMENT_PERIOD_SECONDS'] || 10.minutes).to_i
  throttle('payment/ip', limit: payment_limit, period: payment_period) do |req|
    req.ip if req.path.start_with?('/payments/') && req.post?
  end
  
  # 파일 업로드: IP당 10분에 20번
  throttle('upload/ip', limit: 20, period: 10.minutes) do |req|
    req.ip if req.path.include?('/upload') && req.post?
  end
  
  # 일반 요청
  req_limit = (ENV['RACK_ATTACK_REQ_LIMIT'] || 300).to_i
  req_period = (ENV['RACK_ATTACK_REQ_PERIOD_SECONDS'] || 1.minute).to_i
  throttle('req/ip', limit: req_limit, period: req_period) do |req|
    req.ip
  end
  
  ### Blocklist (차단 목록) ###
  
  # 특정 IP 차단 (프로덕션에서 설정)
  # blocklist('block-bad-ips') do |req|
  #   # 차단할 IP 목록
  #   ['1.2.3.4', '5.6.7.8'].include?(req.ip)
  # end
  
  ### 커스텀 응답 ###
  
  # 요청 제한 초과 시 응답
  self.throttled_responder = lambda do |env|
    retry_after = env['rack.attack.match_data'][:period]
    [
      429,
      {
        'Content-Type' => 'text/html',
        'Retry-After' => retry_after.to_s
      },
      [ActionController::Base.render(file: Rails.root.join('app', 'views', 'errors', 'too_many_requests.html.erb'), layout: false)]
    ]
  end
  
  # 차단된 요청 응답
  self.blocklisted_responder = lambda do |_env|
    [
      403,
      { 'Content-Type' => 'text/html' },
      [<<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>접근 차단</title>
        </head>
        <body>
          <h1>⛔ 접근이 차단되었습니다</h1>
          <p>문의: info@jeonghwa.com</p>
        </body>
        </html>
      HTML
      ]
    ]
  end
  
  ### ActiveSupport::Notifications (로깅) ###
  
  ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    
    if [:throttle, :blocklist].include?(req.env['rack.attack.match_type'])
      Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']} " \
                        "#{req.ip} #{req.request_method} #{req.fullpath} " \
                        "match: #{req.env['rack.attack.matched']}"
    end
  end
end



