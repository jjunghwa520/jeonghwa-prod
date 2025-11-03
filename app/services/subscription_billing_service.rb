class SubscriptionBillingService
  # 토스페이먼츠 자동결제(빌링) 연동
  
  def initialize(subscription)
    @subscription = subscription
    @user = subscription.user
  end
  
  # 자동 갱신 처리
  def process_auto_renewal
    return false unless @subscription.auto_renew?
    return false unless @subscription.end_date == Date.today
    
    # 빌링키로 자동 결제 요청
    result = charge_with_billing_key
    
    if result[:success]
      renew_subscription
      send_renewal_notification
      true
    else
      handle_payment_failure(result[:error])
      false
    end
  end
  
  # 빌링키로 결제
  def charge_with_billing_key
    return { success: false, error: 'No billing key' } unless @subscription.billing_key
    
    begin
      # 토스페이먼츠 빌링 API 호출
      response = request_toss_billing_payment
      
      if response['status'] == 'DONE'
        {
          success: true,
          payment_key: response['paymentKey'],
          amount: response['totalAmount']
        }
      else
        {
          success: false,
          error: response['message'] || 'Payment failed'
        }
      end
    rescue => e
      {
        success: false,
        error: e.message
      }
    end
  end
  
  # 구독 갱신
  def renew_subscription
    @subscription.update(
      start_date: @subscription.end_date + 1.day,
      end_date: @subscription.end_date + 1.month,
      status: 'active'
    )
  end
  
  # 실패 처리
  def handle_payment_failure(error_message)
    @subscription.update(status: 'paused')
    
    # 사용자에게 알림
    send_payment_failure_notification(error_message)
    
    # 관리자에게 알림
    notify_admin_of_failure
  end
  
  # 일괄 자동갱신 처리
  def self.process_all_renewals
    subscriptions = Subscription.where(
      auto_renew: true,
      status: 'active',
      end_date: Date.today
    )
    
    results = {
      success: 0,
      failed: 0,
      total: subscriptions.count
    }
    
    subscriptions.each do |subscription|
      service = new(subscription)
      if service.process_auto_renewal
        results[:success] += 1
      else
        results[:failed] += 1
      end
    end
    
    results
  end
  
  # 정산 보고서 생성
  def self.generate_settlement_report(start_date, end_date)
    subscriptions = Subscription.where(created_at: start_date..end_date)
    
    report = {
      period: "#{start_date} ~ #{end_date}",
      total_subscriptions: subscriptions.count,
      active_subscriptions: subscriptions.active.count,
      total_revenue: subscriptions.sum(:price),
      by_plan: {}
    }
    
    Subscription::PLAN_TYPES.each_key do |plan|
      plan_subs = subscriptions.where(plan_type: plan)
      report[:by_plan][plan] = {
        count: plan_subs.count,
        revenue: plan_subs.sum(:price)
      }
    end
    
    report
  end
  
  private
  
  def request_toss_billing_payment
    # 실제 토스페이먼츠 API 호출
    # 여기서는 시뮬레이션
    {
      'status' => 'DONE',
      'paymentKey' => "payment_#{SecureRandom.hex(10)}",
      'totalAmount' => @subscription.price
    }
  end
  
  def send_renewal_notification
    # 이메일 또는 알림 전송
    Rails.logger.info "Subscription renewed for user #{@user.id}"
  end
  
  def send_payment_failure_notification(error)
    # 결제 실패 알림
    Rails.logger.error "Payment failed for subscription #{@subscription.id}: #{error}"
  end
  
  def notify_admin_of_failure
    # 관리자 알림
    Rails.logger.warn "Admin notification: Subscription #{@subscription.id} payment failed"
  end
end

