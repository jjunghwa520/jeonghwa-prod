class SessionsController < ApplicationController
  before_action :throttle_login_in_dev, only: :create
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticate(params[:password])
      Rails.cache.delete("login_attempts:#{request.ip}") if Rails.env.development?
      reset_session          # 세션 픽세이션 방지
      session[:user_id] = user.id
      flash[:notice] = "#{user.name}님, 환영합니다!"
      redirect_to root_path, status: :see_other
    else
      flash.now[:alert] = "이메일 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session           # 전체 세션 초기화
    flash[:notice] = "로그아웃되었습니다."
    redirect_to root_path, status: :see_other
  end

  private

  def throttle_login_in_dev
    return unless Rails.env.development?
    key = "login_attempts:#{request.ip}"
    count = Rails.cache.read(key).to_i
    if count >= 5
      retry_after = 60
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head><meta charset="utf-8"><title>요청 제한 초과</title></head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif; display:flex;align-items:center;justify-content:center;height:100vh;margin:0;background:linear-gradient(135deg,#667eea,#764ba2)">
          <div style="text-align:center;background:#fff;padding:3rem;border-radius:20px;box-shadow:0 20px 60px rgba(0,0,0,0.3)">
            <h1>🚦</h1>
            <h2>너무 많은 요청입니다</h2>
            <p>잠시 후 다시 시도해주세요.<br><strong>#{retry_after / 60}분</strong> 후에 다시 이용하실 수 있습니다.</p>
          </div>
        </body>
        </html>
      HTML
      response.set_header('Retry-After', retry_after.to_s)
      render html: html.html_safe, status: :too_many_requests
    else
      Rails.cache.write(key, count + 1, expires_in: 60)
    end
  end
end
