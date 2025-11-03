class DrmService
  # 콘텐츠 암호화 및 워터마크 서비스
  
  def initialize(user, course)
    @user = user
    @course = course
  end
  
  # 콘텐츠 접근 권한 확인
  def can_access?
    return false unless @user
    
    # 관리자는 모든 콘텐츠 접근 가능
    return true if @user.admin?
    
    # 작가는 자신의 콘텐츠 접근 가능
    return true if @course.instructor_id == @user.id
    
    # 구매한 경우
    return true if purchased?
    
    # 프리미엄 구독자
    return true if @user.premium_subscriber?
    
    # 일반 구독자 (월 10개 제한)
    if @user.basic_subscriber?
      monthly_views = ContentView.where(
        user: @user,
        viewed_at: Date.today.beginning_of_month..Date.today.end_of_month
      ).distinct.count(:course_id)
      
      return monthly_views < 10
    end
    
    false
  end
  
  # 워터마크가 추가된 콘텐츠 URL 생성
  def generate_watermarked_url
    return nil unless can_access?
    
    # 사용자 정보로 워터마크 생성
    watermark_text = "#{@user.email} - #{Time.current.strftime('%Y-%m-%d %H:%M')}"
    
    # 서명된 URL 생성 (만료 시간 포함)
    signed_params = {
      user_id: @user.id,
      course_id: @course.id,
      watermark: Base64.strict_encode64(watermark_text),
      expires_at: 24.hours.from_now.to_i
    }
    
    token = generate_token(signed_params)
    
    {
      url: "/courses/#{@course.id}/secure_view",
      token: token,
      watermark: watermark_text,
      expires_at: signed_params[:expires_at]
    }
  end
  
  # 콘텐츠 복사 방지 설정
  def copy_protection_config
    {
      disable_right_click: true,
      disable_text_selection: true,
      disable_print: true,
      disable_screenshot: true,  # JavaScript로 제한 (완전 방지는 불가)
      watermark_overlay: true,
      session_timeout: 3600  # 1시간
    }
  end
  
  # 조회 기록 저장
  def record_view(duration = nil)
    ContentView.create(
      user: @user,
      course: @course,
      viewed_at: Time.current,
      duration: duration
    )
  end
  
  # 토큰 검증
  def self.verify_token(token)
    begin
      payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')[0]
      
      # 만료 확인
      return nil if payload['expires_at'].to_i < Time.current.to_i
      
      payload
    rescue JWT::DecodeError
      nil
    end
  end
  
  private
  
  def purchased?
    Enrollment.exists?(user: @user, course: @course)
  end
  
  def generate_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end

