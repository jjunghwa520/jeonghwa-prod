class GenerateEbookPagesWithStoriesJob < ApplicationJob
  queue_as :default

  def perform(course_id, page_stories, options = {})
    course = Course.find(course_id)
    style = options[:style] || 'watercolor'
    color_tone = options[:color_tone] || 'pastel'
    resolution = options[:resolution] || '1024x1024'
    regenerate = options[:regenerate] || false
    
    pages_dir = Rails.root.join('public', 'ebooks', course_id.to_s, 'pages')
    
    # 재생성이면 기존 파일 백업
    if regenerate && Dir.exist?(pages_dir)
      backup_dir = Rails.root.join('public', 'ebooks', course_id.to_s, "pages_backup_#{Time.now.to_i}")
      FileUtils.cp_r(pages_dir, backup_dir)
      Rails.logger.info "기존 파일 백업: #{backup_dir}"
    end
    
    FileUtils.mkdir_p(pages_dir)
    
    page_stories.each_with_index do |story, index|
      page_num = index + 1
      
      begin
        # 프롬프트 생성
        prompt = build_image_prompt(story, style, color_tone, page_num, page_stories.count)
        
        # Vertex AI로 이미지 생성
        image_data = generate_image_with_vertex_ai(prompt, resolution)
        
        # 파일 저장
        filename = "page_#{page_num.to_s.rjust(3, '0')}.jpg"
        filepath = pages_dir.join(filename)
        File.binwrite(filepath, image_data)
        
        # 캡션 저장
        caption_file = filepath.to_s.gsub('.jpg', '.txt')
        File.write(caption_file, story)
        
        Rails.logger.info "페이지 #{page_num}/#{page_stories.count} 생성 완료: #{filename}"
        
        # Rate limiting
        sleep(2) unless page_num == page_stories.count
        
      rescue => e
        Rails.logger.error "페이지 #{page_num} 생성 실패: #{e.message}"
        # 계속 진행
      end
    end
    
    Rails.logger.info "#{course.title} 전체 페이지 생성 완료!"
  end
  
  private
  
  def build_image_prompt(story, style, color_tone, page_num, total_pages)
    style_text = case style
                 when 'watercolor' then 'watercolor painting style'
                 when 'digital' then 'digital art illustration'
                 when 'cartoon' then 'cartoon comic book style'
                 when 'pixar' then '3D Pixar animation style'
                 else 'children\'s book illustration'
                 end
    
    color_text = case color_tone
                 when 'pastel' then 'soft pastel colors'
                 when 'vibrant' then 'vibrant bright colors'
                 when 'soft' then 'gentle soft tones'
                 when 'warm' then 'warm cozy atmosphere'
                 else 'pleasant colors'
                 end
    
    "#{story}, #{style_text}, #{color_text}, children's fairy tale picture book, " \
    "professional illustration, warm soft lighting, whimsical atmosphere, " \
    "clean composition, high quality, suitable for children ages 3-7"
  end
  
  def generate_image_with_vertex_ai(prompt, resolution)
    # Vertex AI Imagen 호출
    # 실제 구현은 lib/tasks/title_specific_vertex.rake 참고
    
    require 'google/cloud/ai_platform/v1'
    require 'base64'
    
    # TODO: 실제 Vertex AI 구현
    # 현재는 placeholder
    
    Rails.logger.info "Vertex AI 호출: #{prompt[0..100]}..."
    
    # Placeholder: 실제로는 Vertex AI 호출
    # 임시로 빈 이미지 데이터 반환 (실제 구현 필요)
    raise NotImplementedError, "Vertex AI 연동 구현 필요"
  end
end

