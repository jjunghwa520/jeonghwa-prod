class PaymentsController < ApplicationController
  before_action :require_login
  before_action :set_course, only: [:checkout, :confirm]
  
  # 결제 시작
  def checkout
    # 이미 결제했거나 무료 코스 체크
    if current_user.enrolled_courses.include?(@course)
      redirect_to @course, alert: "이미 수강 중인 강의입니다."
      return
    end
    
    if @course.price.to_f == 0
      # 무료 코스는 바로 등록
      current_user.enrollments.create(course: @course)
      redirect_to @course, notice: "무료 수강이 시작되었습니다!"
      return
    end
    
    # 주문 생성
    @order = Order.create!(
      user: current_user,
      course: @course,
      amount: @course.price,
      status: 'pending',
      order_id: generate_order_id
    )
    
    # 토스페이먼츠 설정
    @toss_client_key = ENV.fetch('TOSS_CLIENT_KEY') do
      Rails.logger.warn "TOSS_CLIENT_KEY not set, using test key"
      'test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq'
    end
    @order_name = @course.title.truncate(100)
  end
  
  # 결제 승인
  def confirm
    payment_key = params[:paymentKey]
    order_id = params[:orderId]
    amount = params[:amount].to_i
    
    order = Order.find_by(order_id: order_id)
    
    unless order
      redirect_to root_path, alert: "주문을 찾을 수 없습니다."
      return
    end
    
    # 토스페이먼츠 API로 결제 승인
    secret_key = ENV.fetch('TOSS_SECRET_KEY') do
      Rails.logger.warn "TOSS_SECRET_KEY not set, using test key"
      'test_sk_zXLkKEypNArWmo50nX3lmeaxYG5R'
    end
    auth = Base64.strict_encode64("#{secret_key}:")
    
    uri = URI('https://api.tosspayments.com/v1/payments/confirm')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Basic #{auth}"
    request['Content-Type'] = 'application/json'
    request.body = {
      paymentKey: payment_key,
      orderId: order_id,
      amount: amount
    }.to_json
    
    response = http.request(request)
    result = JSON.parse(response.body)
    
    if response.code == '200'
      # 결제 성공
      order.update!(
        status: 'completed',
        payment_key: payment_key,
        approved_at: Time.current
      )
      
      # 자동 수강 등록
      current_user.enrollments.create!(course: order.course)
      
      redirect_to order.course, notice: "결제가 완료되었습니다! 지금 바로 수강하세요."
    else
      # 결제 실패
      order.update!(
        status: 'failed',
        error_message: result['message']
      )
      
      redirect_to root_path, alert: "결제 실패: #{result['message']}"
    end
  rescue => e
    redirect_to root_path, alert: "결제 처리 중 오류: #{e.message}"
  end
  
  # 결제 실패 처리
  def fail
    code = params[:code]
    message = params[:message]
    order_id = params[:orderId]
    
    order = Order.find_by(order_id: order_id)
    order&.update(status: 'failed', error_message: message)
    
    redirect_to root_path, alert: "결제가 취소되었습니다: #{message}"
  end
  
  # 환불 처리
  def refund
    @order = Order.find(params[:id])
    
    # 권한 체크: 본인 주문 또는 관리자만
    unless @order.user == current_user || current_user.admin?
      redirect_to root_path, alert: "권한이 없습니다."
      return
    end
    
    # 환불 가능 상태 체크
    unless @order.status == 'completed'
      redirect_to user_orders_path(current_user), alert: "환불 가능한 주문이 아닙니다."
      return
    end
    
    # 환불 사유
    refund_reason = params[:refund_reason] || "사용자 요청"
    
    # 토스페이먼츠 환불 API 호출
    secret_key = ENV.fetch('TOSS_SECRET_KEY') do
      Rails.logger.warn "TOSS_SECRET_KEY not set, using test key"
      'test_sk_zXLkKEypNArWmo50nX3lmeaxYG5R'
    end
    auth = Base64.strict_encode64("#{secret_key}:")
    
    uri = URI("https://api.tosspayments.com/v1/payments/#{@order.payment_key}/cancel")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Basic #{auth}"
    request['Content-Type'] = 'application/json'
    request.body = {
      cancelReason: refund_reason
    }.to_json
    
    response = http.request(request)
    result = JSON.parse(response.body)
    
    if response.code == '200'
      # 환불 성공
      @order.update!(
        status: 'refunded',
        refunded_at: Time.current,
        refund_reason: refund_reason
      )
      
      # 수강 등록 취소
      enrollment = @order.user.enrollments.find_by(course: @order.course)
      enrollment&.destroy
      
      redirect_to user_orders_path(current_user), notice: "환불이 완료되었습니다. 영업일 기준 3-5일 내에 환불 처리됩니다."
    else
      # 환불 실패
      redirect_to user_orders_path(current_user), alert: "환불 실패: #{result['message']}"
    end
  rescue => e
    redirect_to user_orders_path(current_user), alert: "환불 처리 중 오류: #{e.message}"
  end

  # 토스페이먼츠 웹훅 처리 (성공/실패/환불)
  skip_before_action :verify_authenticity_token, only: [:webhook]
  def webhook
    begin
      payload = JSON.parse(request.raw_post) rescue {}
      event_type = payload["status"] || payload["eventType"]
      order_id = payload["orderId"] || payload.dig("data", "orderId")
      payment_key = payload["paymentKey"] || payload.dig("data", "paymentKey")

      order = Order.find_by(order_id: order_id)
      head :ok and return unless order

      case event_type
      when "DONE", "APPROVED", "SUCCESS"
        order.update!(status: 'completed', payment_key: payment_key, approved_at: Time.current)
      when "CANCELED", "CANCELLED", "PARTIAL_CANCELED"
        order.update!(status: 'refunded', refunded_at: Time.current)
      when "FAILED"
        order.update!(status: 'failed', error_message: payload["message"])
      end

      head :ok
    rescue => e
      Rails.logger.error("[TossWebhook] error=#{e.class} #{e.message}")
      head :bad_request
    end
  end
  
  private
  
  def set_course
    @course = Course.find(params[:course_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "코스를 찾을 수 없습니다."
  end
  
  def generate_order_id
    "ORDER_#{Time.current.strftime('%Y%m%d%H%M%S')}_#{SecureRandom.hex(4).upcase}"
  end
end

