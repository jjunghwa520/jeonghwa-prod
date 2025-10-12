class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :current_user

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
end
