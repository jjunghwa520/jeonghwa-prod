namespace :content do
  desc "Generate ebook pages automatically using Vertex AI"
  task :generate_ebook_pages, [:course_id, :page_count] => :environment do |t, args|
    require 'google/cloud/ai_platform/v1'
    require 'googleauth'
    require 'json'
    require 'base64'
    require 'net/http'
    
    course_id = args[:course_id] || ENV['COURSE_ID']
    page_count = (args[:page_count] || ENV['PAGE_COUNT'] || '15').to_i
    
    abort("❌ Usage: rake content:generate_ebook_pages[COURSE_ID,PAGE_COUNT]") unless course_id
    
    course = Course.find_by(id: course_id)
    abort("❌ Course #{course_id} not found") unless course
    
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_path = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"] || 
                Rails.root.join("config", "google_service_account.json").to_s
    
    abort("❌ Credentials file not found: #{cred_path}") unless File.exist?(cred_path)
    
    puts "\n" + "="*80
    puts "🎨 Vertex AI 전자동화책 페이지 자동 생성"
    puts "="*80
    puts "📚 코스: #{course.title} (ID: #{course_id})"
    puts "📄 생성할 페이지 수: #{page_count}장"
    puts "🔑 프로젝트: #{project_id}"
    puts "="*80 + "\n"
    
    # 저장 디렉토리
    pages_dir = Rails.root.join('public', 'ebooks', course_id.to_s, 'pages')
    FileUtils.mkdir_p(pages_dir)
    
    # Vertex AI 클라이언트 설정
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = cred_path
    location = 'us-central1'
    endpoint = "#{location}-aiplatform.googleapis.com"
    model = 'imagegeneration@006'
    
    # 코스 제목 기반 기본 프롬프트 생성
    base_prompt = generate_story_prompt(course.title, course.description)
    
    puts "📝 기본 프롬프트: #{base_prompt}\n\n"
    
    success_count = 0
    failed_pages = []
    
    page_count.times do |i|
      page_num = i + 1
      filename = "page_%03d.jpg" % page_num
      output_path = pages_dir.join(filename)
      
      # 이미 존재하면 스킵
      if File.exist?(output_path)
        puts "⏭️  페이지 #{page_num}: 이미 존재 (#{filename})"
        success_count += 1
        next
      end
      
      # 페이지별 프롬프트 생성
      page_prompt = generate_page_prompt(base_prompt, page_num, page_count)
      
      puts "🎨 페이지 #{page_num}/#{page_count} 생성 중..."
      puts "   프롬프트: #{page_prompt[0..100]}..."
      
      begin
        # Vertex AI API 호출
        image_data = call_vertex_imagen(
          project_id: project_id,
          location: location,
          prompt: page_prompt,
          credentials_path: cred_path
        )
        
        if image_data
          File.binwrite(output_path, image_data)
          puts "   ✅ 저장: #{filename} (#{(image_data.size / 1024.0).round(1)}KB)"
          success_count += 1
          
          # Rate limiting (Vertex AI quota 보호)
          sleep 2 if page_num < page_count
        else
          puts "   ❌ 생성 실패"
          failed_pages << page_num
        end
        
      rescue => e
        puts "   ❌ 에러: #{e.message}"
        failed_pages << page_num
      end
    end
    
    # 캡션 파일 생성
    puts "\n📝 캡션 파일 생성 중..."
    generate_caption_files(course, pages_dir, page_count)
    
    # 결과 요약
    puts "\n" + "="*80
    puts "✨ 생성 완료!"
    puts "="*80
    puts "✅ 성공: #{success_count}/#{page_count}장"
    puts "❌ 실패: #{failed_pages.length}장 #{failed_pages.any? ? "(페이지: #{failed_pages.join(', ')})" : ''}"
    puts "📁 저장 경로: #{pages_dir}"
    puts "="*80 + "\n"
  end
  
  # 코스 제목/설명 기반 스토리 프롬프트 생성
  def generate_story_prompt(title, description)
    clean_title = title.gsub(/[🦁🧚‍♀️🐰🐻🦊🐧🦋🐢🦉🐿️🎭🏰🐺🐷🌹🐸👸🏃🍎🦢📝🎨📚🏆✏️🎭🌈📖💡🎪\s]+/, ' ').strip
    
    # 제목에서 핵심 키워드 추출
    if clean_title.include?("사자")
      "Brave lion character in storybook adventure"
    elsif clean_title.include?("요정")
      "Magical fairy in enchanted forest"
    elsif clean_title.include?("토끼")
      "Cute rabbit on moon adventure"
    elsif clean_title.include?("곰")
      "Friendly bear with bee friends"
    elsif clean_title.include?("여우")
      "Clever fox making wise choices"
    elsif clean_title.include?("펭귄")
      "Penguin exploring ice kingdom"
    elsif clean_title.include?("나비")
      "Butterfly transformation story"
    elsif clean_title.include?("거북")
      "Patient turtle on slow journey"
    elsif clean_title.include?("부엉이")
      "Wise owl teaching night school"
    elsif clean_title.include?("다람쥐")
      "Squirrel saving acorns"
    else
      "Children's fairy tale storybook illustration"
    end
  end
  
  # 페이지별 프롬프트 생성 (스토리 진행에 따라)
  def generate_page_prompt(base_prompt, page_num, total_pages)
    stage = if page_num == 1
      "opening scene, introduction"
    elsif page_num <= total_pages * 0.3
      "beginning of adventure, meeting characters"
    elsif page_num <= total_pages * 0.7
      "main conflict and challenges"
    elsif page_num < total_pages
      "climax and resolution"
    else
      "happy ending, conclusion"
    end
    
    negative = "text, typography, watermark, logo, photorealistic, harsh lighting, clutter, grain"
    
    "#{base_prompt}, #{stage}, children's picture book illustration, warm lighting, soft colors, " +
    "whimsical atmosphere, high-quality digital art, clean composition, no #{negative}"
  end
  
  # Vertex AI Imagen API 호출
  def call_vertex_imagen(project_id:, location:, prompt:, credentials_path:)
    require 'googleauth'
    require 'net/http'
    require 'json'
    
    # 인증 토큰 획득
    scopes = ['https://www.googleapis.com/auth/cloud-platform']
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(credentials_path),
      scope: scopes
    )
    token = authorizer.fetch_access_token!['access_token']
    
    # API 엔드포인트
    endpoint = "https://#{location}-aiplatform.googleapis.com"
    model = "imagegeneration@006"
    url = "#{endpoint}/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/#{model}:predict"
    
    # 요청 페이로드
    payload = {
      instances: [{
        prompt: prompt
      }],
      parameters: {
        sampleCount: 1,
        aspectRatio: "3:4",  # 동화책 비율
        safetyFilterLevel: "block_some",
        personGeneration: "allow_adult"
      }
    }
    
    # HTTP 요청
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120
    
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    
    if response.code.to_i == 200
      result = JSON.parse(response.body)
      predictions = result['predictions']
      
      if predictions&.any? && predictions[0]['bytesBase64Encoded']
        return Base64.decode64(predictions[0]['bytesBase64Encoded'])
      end
    else
      puts "   ⚠️  API 응답 코드: #{response.code}"
    end
    
    nil
  rescue => e
    puts "   ⚠️  API 호출 실패: #{e.message}"
    nil
  end
  
  # 캡션 파일 생성
  def generate_caption_files(course, pages_dir, page_count)
    page_count.times do |i|
      page_num = i + 1
      caption_file = pages_dir.join("page_%03d.txt" % page_num)
      
      next if File.exist?(caption_file)
      
      # 간단한 캡션 생성 (실제로는 Gemini API 사용 권장)
      caption = if page_num == 1
        "#{course.title}의 시작입니다. 주인공을 만나보세요!"
      elsif page_num <= page_count * 0.3
        "모험이 시작됩니다. 어떤 일이 일어날까요?"
      elsif page_num <= page_count * 0.7
        "긴장감이 높아집니다. 주인공은 어떻게 할까요?"
      elsif page_num < page_count
        "드디어 문제가 해결됩니다!"
      else
        "행복한 결말입니다. 모두 함께 기뻐해요!"
      end
      
      File.write(caption_file, caption)
    end
    
    puts "   ✅ 캡션 #{page_count}개 생성 완료"
  end
end

namespace :content do
  desc "Batch generate ebooks for multiple courses"
  task :batch_generate_ebooks => :environment do
    # 페이지가 없는 전자동화책 코스 찾기
    ebook_courses = Course.where(category: ['전자동화책', 'ebook', '동화책'])
    
    missing_pages = []
    ebook_courses.each do |course|
      pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
      page_count = Dir.glob(pages_dir.join('page_*.{jpg,png}')).count
      
      if page_count == 0
        missing_pages << course
      end
    end
    
    puts "📊 페이지 없는 전자동화책: #{missing_pages.count}개"
    missing_pages.each do |course|
      puts "   - ID #{course.id}: #{course.title}"
    end
    
    if missing_pages.any?
      puts "\n🚀 자동 생성을 시작합니다...\n"
      
      missing_pages.each_with_index do |course, idx|
        puts "\n[#{idx + 1}/#{missing_pages.count}] #{course.title}"
        Rake::Task['content:generate_ebook_pages'].reenable
        Rake::Task['content:generate_ebook_pages'].invoke(course.id.to_s, '15')
        
        sleep 3 # API quota 보호
      end
      
      puts "\n✨ 전체 배치 생성 완료!"
    else
      puts "✅ 모든 전자동화책이 페이지를 가지고 있습니다!"
    end
  end
end

