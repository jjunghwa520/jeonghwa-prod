module GeneratedImagesHelper
  def status_color(status)
    case status
    when 'completed'
      'success'
    when 'processing'
      'warning'
    when 'failed'
      'danger'
    when 'pending'
      'secondary'
    else
      'light'
    end
  end
  
  def status_text(status)
    case status
    when 'completed'
      '완료'
    when 'processing'
      '처리 중'
    when 'failed'
      '실패'
    when 'pending'
      '대기 중'
    else
      status
    end
  end
  
  def image_type_text(type)
    case type
    when 'banner'
      '배너'
    when 'thumbnail'
      '썸네일'
    when 'hero'
      '히어로 이미지'
    when 'course_image'
      '코스 이미지'
    when 'profile'
      '프로필 이미지'
    else
      type
    end
  end
  
  def style_text(style)
    case style
    when 'modern'
      '모던'
    when 'educational'
      '교육적'
    when 'professional'
      '전문적'
    when 'creative'
      '창의적'
    else
      style
    end
  end
end
