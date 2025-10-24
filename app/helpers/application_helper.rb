module ApplicationHelper
  def order_status_text(status)
    case status
    when 'pending'
      '결제 대기'
    when 'completed'
      '결제 완료'
    when 'failed'
      '결제 실패'
    when 'cancelled'
      '결제 취소'
    when 'refunded'
      '환불 완료'
    else
      status
    end
  end
  
  def order_status_class(status)
    case status
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'completed'
      'bg-green-100 text-green-800'
    when 'failed', 'cancelled'
      'bg-gray-100 text-gray-800'
    when 'refunded'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  # SEO 메타태그 헬퍼 메소드
  def meta_title(title = nil)
    base_title = "정화의 서재"
    title.present? ? "#{title} - #{base_title}" : base_title
  end

  def meta_description(description = nil)
    description.presence || "아이들의 상상력을 키우는 특별한 동화책 플랫폼. 전자동화책, 구연동화, 동화 만들기 교육을 만나보세요."
  end

  def meta_keywords(keywords = [])
    base_keywords = %w[동화책 전자동화책 구연동화 어린이책 그림책 동화만들기 교육콘텐츠 정화의서재]
    (base_keywords + keywords).uniq.join(', ')
  end

  def meta_image(image_url = nil)
    if image_url.present?
      # 상대 경로면 절대 URL로 변환
      image_url.start_with?('http') ? image_url : request.base_url + image_url
    else
      # 기본 OG 이미지 (추후 생성 필요)
      request.base_url + '/assets/og-default.jpg'
    end
  end

  # Open Graph 메타태그 생성
  def og_meta_tags(options = {})
    {
      'og:site_name' => '정화의 서재',
      'og:type' => options[:type] || 'website',
      'og:title' => options[:title].presence || '정화의 서재 - 아이들의 상상력을 키우는 동화책 플랫폼',
      'og:description' => meta_description(options[:description]),
      'og:image' => meta_image(options[:image]),
      'og:url' => request.original_url,
      'og:locale' => 'ko_KR',
      'twitter:card' => 'summary_large_image',
      'twitter:title' => options[:title].presence || '정화의 서재 - 아이들의 상상력을 키우는 동화책 플랫폼',
      'twitter:description' => meta_description(options[:description]),
      'twitter:image' => meta_image(options[:image])
    }
  end
end
