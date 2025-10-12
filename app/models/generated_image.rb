class GeneratedImage < ApplicationRecord
  # 연관 관계
  belongs_to :user, optional: true
  belongs_to :course, optional: true
  
  # 유효성 검사
  validates :prompt, presence: true
  validates :image_type, inclusion: { in: %w[banner thumbnail hero course_image profile] }
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  
  # 스코프
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_type, ->(type) { where(image_type: type) }
  
  # 콜백
  before_validation :set_defaults
  
  # 이미지 생성 요청
  def generate!
    update!(status: 'processing', started_at: Time.current)
    
    service = VertexAiService.new
    
    # 이미지 타입에 따른 생성
    image_url = case image_type
    when 'banner'
      service.generate_banner(prompt, metadata['description'] || '', style: style)
    when 'thumbnail', 'course_image'
      service.generate_course_thumbnail(prompt, metadata['description'] || '')
    else
      service.generate_image(prompt, style: style, size: size)
    end
    
    if image_url
      update!(
        status: 'completed',
        image_url: image_url,
        completed_at: Time.current,
        generation_time: Time.current - started_at
      )
    else
      update!(
        status: 'failed',
        error_message: 'Image generation failed',
        completed_at: Time.current
      )
    end
  rescue => e
    update!(
      status: 'failed',
      error_message: e.message,
      completed_at: Time.current
    )
    Rails.logger.error "Image generation failed: #{e.message}"
  end
  
  # 비동기 생성
  def generate_async!
    GenerateImageJob.perform_later(self)
  end
  
  # 재시도
  def retry!
    return false if status == 'processing'
    
    update!(
      status: 'pending',
      error_message: nil,
      started_at: nil,
      completed_at: nil,
      retry_count: retry_count + 1
    )
    
    generate_async!
  end
  
  # 이미지 사용 가능 여부
  def available?
    status == 'completed' && image_url.present?
  end
  
  # 처리 중인지 확인
  def processing?
    status == 'processing'
  end
  
  # 실패했는지 확인
  def failed?
    status == 'failed'
  end
  
  private
  
  def set_defaults
    self.status ||= 'pending'
    self.style ||= 'modern'
    self.size ||= '1024x1024'
    self.metadata ||= {}
    self.retry_count ||= 0
  end
end
