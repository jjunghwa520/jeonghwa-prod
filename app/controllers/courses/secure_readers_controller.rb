class Courses::SecureReadersController < ApplicationController
  before_action :require_login
  before_action :set_course
  before_action :verify_access
  
  def show
    @drm_service = DrmService.new(current_user, @course)
    @drm_config = @drm_service.copy_protection_config
    @watermark_info = @drm_service.generate_watermarked_url
    
    # 조회 기록
    @drm_service.record_view
    
    # 콘텐츠 로드
    @content = load_secure_content
  end
  
  def track_duration
    duration = params[:duration].to_i
    
    drm_service = DrmService.new(current_user, @course)
    drm_service.record_view(duration)
    
    head :ok
  end
  
  private
  
  def set_course
    @course = Course.find(params[:id])
  end
  
  def verify_access
    drm_service = DrmService.new(current_user, @course)
    
    unless drm_service.can_access?
      flash[:error] = '이 콘텐츠에 접근할 권한이 없습니다.'
      redirect_to course_path(@course)
    end
  end
  
  def load_secure_content
    # 실제 콘텐츠 파일 로드 (PDF, 텍스트 등)
    # 워터마크가 추가된 버전 반환
    {
      title: @course.title,
      content_type: 'text',  # 또는 'pdf', 'video'
      pages: load_pages_with_watermark
    }
  end
  
  def load_pages_with_watermark
    # 실제 구현에서는 파일에서 로드
    [@course.description]  # 임시
  end
  
  def require_login
    unless current_user
      flash[:error] = '로그인이 필요합니다.'
      redirect_to login_path
    end
  end
end

