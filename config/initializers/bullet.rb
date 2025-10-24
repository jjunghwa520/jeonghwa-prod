# frozen_string_literal: true

# Bullet: N+1 쿼리 탐지 도구
# 개발 환경에서만 활성화

if defined?(Bullet) && Rails.env.development?
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = true
      
      # 브라우저 알림은 개발 효율 저하로 비활성화 (로그는 유지)
      Bullet.alert = false
      
      # 로그 파일 기록
      Bullet.bullet_logger = true
      
      # Rails 로그에 출력
      Bullet.rails_logger = true
      
      # 콘솔에 출력
      Bullet.console = true
      
      # N+1 쿼리 탐지
      Bullet.add_footer = true
      
      # Unused eager loading 탐지
      Bullet.unused_eager_loading_enable = true
      
      # Counter cache 제안
      Bullet.counter_cache_enable = true
    end
  end
end



