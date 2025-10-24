module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:update]

    def index
      @q = params[:q].to_s.strip
      @users = User.order(created_at: :desc).limit(200)
      if @q.present?
        @users = @users.select { |u| u.name.include?(@q) || u.email.include?(@q) }
      end
    end

    def update
      if params[:role].present? && %w[student instructor admin].include?(params[:role])
        @user.update(role: params[:role])
        redirect_to admin_users_path, notice: '권한이 업데이트되었습니다.'
      else
        redirect_to admin_users_path, alert: '허용되지 않은 권한 값입니다.'
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end


