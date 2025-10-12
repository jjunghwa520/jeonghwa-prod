namespace :jeonghwa do
  desc "Fix harsh eyes and create gentler, warmer expressions"
  task fix_gentle_eyes: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "👀 매서운 눈 표정 개선 - 부드럽고 따뜻한 눈으로!"
    puts "💝 목표: 아이들이 편안해하는 따뜻한 선생님 눈빛"
    puts "🍌 나노바나나 이미지 편집 기능 활용"
    
    # 기존 Google Service Account를 사용하여 액세스 토큰 생성
    key_file_path = Rails.root.join('config', 'google_service_account.json')
    
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/generative-language']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      token['access_token']
    end

    # 부드러운 눈 표정 생성 함수
    def create_gentle_eyes_character(access_token, prompt, filename)
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}"
      
      payload = {
        contents: [
          {
            parts: [
              {
                text: prompt
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.9,  # 더 부드러운 표현을 위해 온도 상승
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192
        }
      }
      
      request.body = payload.to_json
      
      puts "\n👀 부드러운 눈 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'gentle_eyes')
              FileUtils.mkdir_p(output_dir)
              
              file_path = File.join(output_dir, "#{filename}.png")
              File.open(file_path, 'wb') { |file| file.write(image_data) }
              
              puts "✅ 성공: #{filename}.png (#{(image_data.size / 1024.0 / 1024.0).round(2)}MB)"
              return true
            end
          end
          
          puts "❌ 실패: #{filename} - 이미지 데이터 없음"
          return false
        else
          puts "❌ 실패: #{filename} - 예상치 못한 응답 구조"
          return false
        end
      else
        error_body = JSON.parse(response.body) rescue response.body
        puts "❌ 실패: #{filename} - HTTP #{response.code}"
        puts "📄 오류: #{error_body.dig('error', 'message') || error_body}"
        return false
      end
    rescue => e
      puts "❌ 예외: #{filename} - #{e.message}"
      return false
    end

    begin
      access_token = get_access_token(key_file_path)
      puts "🔑 Google Service Account 액세스 토큰 획득 완료"
      
      # 부드럽고 따뜻한 눈 표정에 특화된 프롬프트들
      gentle_eye_prompts = {
        "jeonghwa_gentle_main" => "Generate a cute 3D figurine character: A professional middle-aged female educator with extremely soft and gentle East Asian facial features, very kind and warm almond-shaped eyes with a slight downward curve that shows gentleness (never sharp or stern), soft crescent-shaped eyes when smiling like a loving grandmother, gentle eyebrows that curve softly, short curly bob hairstyle in warm dark brown, wearing bright royal blue blazer over black top, small pearl necklace, black skirt, the most loving and nurturing smile with eyes that sparkle with kindness and patience, holding colorful books, standing in welcoming pose, 3D collectible toy style with extra soft and rounded features, warm pastel lighting, clean background",
        
        "jeonghwa_gentle_teaching" => "Create a charming 3D figurine: An enthusiastic female instructor with incredibly gentle and kind East Asian eyes that curve downward slightly when smiling (avoiding any sharp or stern look), eyes that twinkle with joy and patience like a beloved kindergarten teacher, soft rounded eyebrows, short wavy bob hair in rich brown, bright blue cardigan over black blouse, pearl necklace, dark skirt, teaching gesture with warm encouraging expression, eyes that show she genuinely loves working with children, 3D toy character style with extra emphasis on soft, nurturing facial features, gentle lighting",
        
        "jeonghwa_gentle_welcome" => "Design an adorable 3D figurine: A welcoming middle-aged female mentor with the softest, most loving East Asian eyes imaginable, eyes that curve gently downward when smiling (like a crescent moon), showing pure warmth and maternal love, no trace of sternness or sharpness, gentle laugh lines that show years of joy working with children, soft eyebrows, short curly bob hair, arms open wide in the most loving greeting, bright blue blazer, pearl necklace, black skirt, expression of pure joy and love for education, holding magical teaching wand, 3D collectible style with maximum emphasis on gentle, nurturing features"
      }

      success_count = 0
      total_count = gentle_eye_prompts.length

      gentle_eye_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "👀 부드러운 눈 표정 생성 #{index + 1}/#{total_count}"
        
        if create_gentle_eyes_character(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(4) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 부드러운 눈 표정 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'gentle_eyes', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n👀 개선된 눈 표정 특징:"
        puts "  - 매서움 완전 제거"
        puts "  - 초승달 모양의 부드러운 눈"
        puts "  - 사랑스러운 할머니 같은 눈빛"
        puts "  - 아이들이 편안해하는 따뜻한 시선"
        puts "  - 인내심과 사랑이 담긴 표정"
        puts "  - 유치원 선생님 같은 온화함"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

