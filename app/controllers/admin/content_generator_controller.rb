module Admin
  class ContentGeneratorController < BaseController
    def index
      @ebook_courses = Course.where(category: ['전자동화책', 'ebook', '동화책'])
      
      # 각 코스의 콘텐츠 상태 확인
      @course_status = @ebook_courses.map do |course|
        pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
        page_files = Dir.glob(pages_dir.join('page_*.{jpg,png}'))
        caption_files = Dir.glob(pages_dir.join('page_*.txt'))
        
        {
          course: course,
          page_count: page_files.count,
          caption_count: caption_files.count,
          status: page_files.any? ? (page_files.count >= 10 ? 'complete' : 'partial') : 'missing'
        }
      end.sort_by { |s| s[:status] == 'missing' ? 0 : (s[:status] == 'partial' ? 1 : 2) }
    end
    
    def generate
      course_id = params[:course_id]
      page_stories = params[:page_stories] || []
      style = params[:style] || 'watercolor'
      color_tone = params[:color_tone] || 'pastel'
      resolution = params[:resolution] || '1024x1024'
      regenerate = params[:regenerate] == 'true'
      
      course = Course.find(course_id)
      
      # 페이지 스토리가 있으면 사용, 없으면 기본 생성
      if page_stories.empty?
        page_count = (params[:page_count] || 15).to_i
        # 기존 자동 생성 방식
        GenerateEbookPagesJob.perform_later(course.id, page_count)
        flash[:notice] = "#{course.title}의 페이지 #{page_count}장 생성이 시작되었습니다."
      else
        # 새로운 방식: 페이지별 스토리 기반 생성
        # 백그라운드 잡으로 실행
        GenerateEbookPagesWithStoriesJob.perform_later(
          course.id,
          page_stories,
          {
            style: style,
            color_tone: color_tone,
            resolution: resolution,
            regenerate: regenerate
          }
        )
        flash[:notice] = "#{course.title}의 페이지 #{page_stories.count}장 생성이 시작되었습니다. (약 #{page_stories.count * 15 / 60}분 소요)"
      end
      
      redirect_to admin_content_generator_index_path
    rescue => e
      Rails.logger.error "AI 생성 오류: #{e.message}\n#{e.backtrace.join("\n")}"
      flash[:alert] = "생성 실패: #{e.message}"
      redirect_to admin_content_generator_index_path
    end
    
    def preview_prompt
      course = Course.find(params[:course_id])
      page_num = (params[:page_num] || 1).to_i
      
      # 프롬프트 미리보기 생성
      base_prompt = generate_story_prompt_preview(course.title)
      full_prompt = generate_page_prompt_preview(base_prompt, page_num, 15)
      
      render json: {
        title: course.title,
        page_num: page_num,
        base_prompt: base_prompt,
        full_prompt: full_prompt
      }
    end
    
    private
    
    def generate_story_prompt_preview(title)
      clean_title = title.gsub(/[🦁🧚‍♀️🐰🐻🦊🐧🦋🐢🦉🐿️🎭🏰🐺🐷🌹🐸👸🏃🍎🦢📝🎨📚🏆✏️🎭🌈📖💡🎪\s]+/, ' ').strip
      
      case clean_title
      when /사자/ then "Brave lion character in storybook adventure"
      when /요정/ then "Magical fairy in enchanted forest"
      when /토끼/ then "Cute rabbit on moon adventure"
      when /곰/ then "Friendly bear with bee friends"
      when /여우/ then "Clever fox making wise choices"
      when /펭귄/ then "Penguin exploring ice kingdom"
      when /나비/ then "Butterfly transformation story"
      when /거북/ then "Patient turtle on slow journey"
      when /부엉이/ then "Wise owl teaching night school"
      when /다람쥐/ then "Squirrel saving acorns"
      else "Children's fairy tale storybook illustration"
      end
    end
    
    def generate_page_prompt_preview(base_prompt, page_num, total_pages)
      stage = if page_num == 1
        "opening scene, title page introduction"
      elsif page_num <= total_pages * 0.3
        "beginning of adventure, meeting new friends"
      elsif page_num <= total_pages * 0.7
        "main conflict and exciting challenges"
      elsif page_num < total_pages
        "climax and problem resolution"
      else
        "happy ending, everyone celebrating"
      end
      
      "#{base_prompt}, #{stage}, children's picture book illustration, warm soft lighting, " +
      "pastel colors, whimsical fairy tale atmosphere, professional digital art, clean composition"
    end
  end
end

