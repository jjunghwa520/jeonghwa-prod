namespace :jeonghwa do
  desc "Create mixed character combining best features from gentle eyes 2 and original 3"
  task create_mixed: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎨 최고 장점 믹스 캐릭터 생성!"
    puts "👀 부드러운 눈빛 2번 + 환영 자세 3번"
    puts "🍌 나노바나나 다중 이미지 합성 기능 활용"
    
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

    # 믹스 캐릭터 생성 함수
    def create_mixed_character(access_token, prompt, filename)
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
          temperature: 0.85,  # 창의적 믹싱을 위한 적절한 온도
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎨 믹스 캐릭터 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'mixed')
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
      
      # 최고 장점 믹스 프롬프트들
      mixed_prompts = {
        "jeonghwa_perfect_mix" => "Create the perfect 3D figurine character combining the best features: A professional middle-aged female educator with incredibly gentle and soft East Asian eyes that curve downward when smiling (like crescent moons, showing pure warmth and love), no trace of sternness or sharpness, the most nurturing and kind expression, short curly bob hairstyle in rich dark brown with natural soft waves, wearing bright royal blue professional blazer over black crew neck top, elegant small white pearl necklace, black A-line knee-length skirt, arms open wide in the most welcoming and loving greeting gesture (like embracing the whole world), holding colorful educational books and magical teaching materials, full body standing pose with perfect proportions, 3D collectible toy aesthetic with maximum emphasis on warmth and approachability, soft pastel lighting that enhances the loving expression, clean white background, educational mascot design that makes both children and parents feel completely safe and welcomed",
        
        "jeonghwa_ultimate_welcome" => "Design the ultimate welcoming educator 3D figurine: Combine the gentlest possible East Asian eyes (soft, crescent-shaped when smiling, full of maternal love) with the most natural and inviting welcoming gesture, middle-aged female educator with round soft facial features, warm genuine smile that reaches the eyes creating gentle laugh lines, short wavy bob hair in dark brown, bright blue blazer over black top, pearl necklace, black skirt, arms positioned in the most natural and loving welcome pose as if greeting beloved students, holding educational materials with care and excitement, perfect body language that says 'I'm so happy to see you', 3D toy character style with emphasis on creating trust and comfort, warm lighting, isolated background",
        
        "jeonghwa_harmony_version" => "Generate a harmonious 3D figurine that perfectly balances professionalism and maternal warmth: A middle-aged female educator with the softest East Asian eyes imaginable (absolutely no sharpness, only gentle curves and warmth), eyes that sparkle with genuine joy for education and love for children, natural gentle eyebrows, short curly bob hairstyle, wearing professional bright blue blazer that shows competence, pearl necklace adding elegance, black skirt, the most natural welcoming pose with arms open but not too wide (showing confidence and invitation), holding beautiful children's books, expression that immediately makes viewers feel 'this is someone I can trust with my child', 3D collectible style with perfect balance of professional and nurturing qualities"
      }

      success_count = 0
      total_count = mixed_prompts.length

      mixed_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🎨 완벽 믹스 캐릭터 생성 #{index + 1}/#{total_count}"
        
        if create_mixed_character(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 완벽 믹스 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 믹스 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'mixed', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎯 완벽 믹스 특징:"
        puts "  - 부드러운 눈빛 2번의 온화한 시선"
        puts "  - 최초 3번의 완벽한 환영 자세"
        puts "  - 매서움 완전 제거된 초승달 눈"
        puts "  - 자연스럽고 사랑스러운 표정"
        puts "  - 전문성과 모성이 조화된 완벽한 밸런스"
        puts "  - 아이들과 부모 모두 신뢰할 수 있는 분위기"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

