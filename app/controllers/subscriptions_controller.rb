class SubscriptionsController < ApplicationController
  before_action :require_login
  before_action :set_subscription, only: [:show, :cancel, :pause, :resume]

  def index
    @subscriptions = current_user.subscriptions.order(created_at: :desc)
    @current_subscription = current_user.current_subscription
  end

  def show
  end

  def new
    @plans = Subscription::PLAN_TYPES
  end

  def create
    plan_type = params[:plan_type]
    plan_info = Subscription::PLAN_TYPES[plan_type.to_sym]

    unless plan_info
      flash[:error] = '유효하지 않은 플랜입니다.'
      redirect_to new_subscription_path and return
    end

    @subscription = current_user.subscriptions.build(
      plan_type: plan_type,
      status: 'pending',  # 결제 완료 후 active로 변경
      start_date: Date.today,
      end_date: Date.today + 1.month,
      price: plan_info[:price],
      auto_renew: params[:auto_renew] == '1'
    )

    if @subscription.save
      # 토스페이먼츠 결제 페이지로 리다이렉트
      redirect_to checkout_subscription_payment_path(@subscription)
    else
      flash[:error] = @subscription.errors.full_messages.join(', ')
      redirect_to new_subscription_path
    end
  end

  def cancel
    if @subscription.cancel!
      flash[:success] = '구독이 취소되었습니다. 현재 기간까지는 계속 이용 가능합니다.'
    else
      flash[:error] = '구독 취소에 실패했습니다.'
    end
    redirect_to subscriptions_path
  end

  def pause
    if @subscription.pause!
      flash[:success] = '구독이 일시 중지되었습니다.'
    else
      flash[:error] = '구독 일시 중지에 실패했습니다.'
    end
    redirect_to subscriptions_path
  end

  def resume
    if @subscription.resume!
      flash[:success] = '구독이 재개되었습니다.'
    else
      flash[:error] = '구독 재개에 실패했습니다.'
    end
    redirect_to subscriptions_path
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = '구독을 찾을 수 없습니다.'
    redirect_to subscriptions_path
  end

  def require_login
    unless current_user
      flash[:error] = '로그인이 필요합니다.'
      redirect_to login_path
    end
  end
end

