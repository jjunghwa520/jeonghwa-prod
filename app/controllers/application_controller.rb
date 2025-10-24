class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :current_user
  before_action :quiet_bullet_alerts_in_dev
  after_action :disable_csp_in_dev
  if defined?(SecureHeaders)
    begin
      ensure_security_headers
    rescue StandardError
      # no-op: ensure_security_headers is provided by secure_headers when loaded
    end
  end

  helper_method :current_user, :logged_in?, :require_login

  private

  def current_user
    return @current_user if defined?(@current_user)
    
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      # 사용자가 존재하지 않으면 세션 정리
      session.delete(:user_id) unless @current_user
    end
    
    @current_user
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "로그인이 필요합니다."
      redirect_to login_path
    end
  end

  def require_instructor
    unless current_user&.instructor?
      flash[:alert] = "강사 권한이 필요합니다."
      redirect_to root_path
    end
  end

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "관리자 권한이 필요합니다."
      redirect_to root_path
    end
  end

  def quiet_bullet_alerts_in_dev
    return unless Rails.env.development?
    return unless defined?(Bullet)
    Bullet.alert = false
  end

  # 보안 헤더 오버라이드: 서버 재시작 없이 jsDelivr 폰트/연결 허용
  # SecureHeaders의 override 기능을 활용해 각 요청 시 적용
  # 개발 환경에서 중복 override 예외가 발생하므로 동적 오버라이드는 제거

  def disable_csp_in_dev
    return unless Rails.env.development?
    response.headers.delete('Content-Security-Policy')
  end
end
