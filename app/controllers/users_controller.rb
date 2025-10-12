class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :dashboard, :my_courses, :my_teachings, :update_role ]
  before_action :require_login, except: [ :new, :create, :show ]
  before_action :require_owner_or_admin, only: [ :edit, :update, :dashboard, :my_courses, :my_teachings ]
  before_action :require_admin, only: [ :update_role ]

  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "회원가입이 완료되었습니다!"
      redirect_to root_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "프로필이 업데이트되었습니다."
      redirect_to @user
    else
      render :edit
    end
  end

  def dashboard
    @enrolled_courses = @user.enrolled_courses.includes(:instructor)
    @taught_courses = @user.taught_courses if @user.instructor?
    @recent_reviews = @user.reviews.recent.limit(5).includes(:course)
  end

  def my_courses
    @enrolled_courses = @user.enrolled_courses.includes(:instructor, :reviews)
  end

  def my_teachings
    require_instructor
    @taught_courses = @user.taught_courses.includes(:students, :reviews)
  end

  # 관리자만 사용자의 role을 변경할 수 있는 메서드
  def update_role
    if @user.update(admin_user_params)
      flash[:notice] = "사용자 권한이 업데이트되었습니다."
      redirect_to @user
    else
      flash[:alert] = "권한 업데이트에 실패했습니다."
      redirect_to @user
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # role 파라미터를 제거하여 일반 사용자가 role을 변경할 수 없도록 함
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :bio, :avatar)
  end

  def admin_user_params
    # 관리자만 role을 변경할 수 있도록 별도 메서드로 분리
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :bio, :avatar)
  end

  def require_owner_or_admin
    unless current_user == @user || current_user&.admin?
      flash[:alert] = "접근 권한이 없습니다."
      redirect_to root_path
    end
  end

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "관리자 권한이 필요합니다."
      redirect_to root_path
    end
  end
end
