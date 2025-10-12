class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticate(params[:password])
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
end
