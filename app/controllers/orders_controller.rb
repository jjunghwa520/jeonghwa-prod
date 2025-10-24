class OrdersController < ApplicationController
  before_action :require_login
  before_action :set_order, only: [:show]
  
  # 주문 내역 목록
  def index
    @user = User.find(params[:user_id])
    
    # 본인 또는 관리자만 접근 가능
    unless @user == current_user || current_user.admin?
      redirect_to root_path, alert: "권한이 없습니다."
      return
    end
    
    @orders = @user.orders.recent.page(params[:page]).per(10)
    
    # 상태별 필터링
    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end
  end
  
  # 주문 상세
  def show
    @user = @order.user
    
    # 본인 또는 관리자만 접근 가능
    unless @user == current_user || current_user.admin?
      redirect_to root_path, alert: "권한이 없습니다."
      return
    end
  end
  
  private
  
  def set_order
    @order = Order.find(params[:id])
  end
end

