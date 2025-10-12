namespace :jeonghwa do
  desc "Generate transparent background Jeonghwa character only"
  task generate_transparent: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎯 배경 없는 순수 정화 캐릭터 생성!"
    puts "🚫 제거: 받침대, 구름, 동물 친구들, 모든 배경 요소"
    puts "✨ 목표: 투명 PNG, 캐릭터만 단독으로"
    puts "🍌 나노바나나 최고급 품질"
    
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

    # 투명 배경 캐릭터 생성 함수
    def generate_transparent_character(access_token, prompt, filename)
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
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎯 투명 캐릭터 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'transparent')
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
      
      # 배경 없는 순수 캐릭터 프롬프트 (배경 요소 완전 제거)
      transparent_prompts = {
        "jeonghwa_clean_main" => "Generate a clean 3D figurine character with absolutely no background elements: A professional middle-aged female educator with soft round East Asian facial features, gentle crescent-shaped eyes that curve downward when smiling, warm rosy cheeks, short curly bob hairstyle in rich dark brown, wearing bright royal blue professional blazer over black crew neck top, elegant white pearl necklace, black A-line knee-length skirt, arms open wide in natural welcoming gesture, holding colorful educational books in one hand, standing in confident pose, 3D collectible toy aesthetic with smooth surfaces, completely isolated character with transparent background, no platform, no base, no environmental elements, no other objects, just the character floating on transparent background",
        
        "jeonghwa_clean_welcome" => "Create a pure 3D figurine character without any background: A welcoming middle-aged female educator with gentle East Asian features, soft crescent eyes full of warmth, round loving face with natural smile, short wavy bob hair in dark brown, wearing professional bright blue blazer over black top, pearl necklace detail, black skirt, arms positioned in loving welcome pose, holding magical teaching wand with subtle sparkle effects, full body standing position with perfect proportions, 3D toy character style with adorable features, completely transparent background with no base, no platform, no surrounding objects, isolated character only",
        
        "jeonghwa_clean_perfect" => "Design the cleanest 3D figurine with zero background elements: A nurturing 40-year-old female educator with soft round East Asian facial characteristics, the gentlest crescent-shaped eyes, warm genuine smile with rosy cheeks, short curly bob hairstyle, bright blue professional jacket over black top, white pearl necklace, black A-line skirt, natural welcoming gesture with arms open, holding educational materials, standing pose with confident but approachable stance, 3D collectible figurine style with smooth surfaces and perfect proportions, absolutely transparent background, no base platform, no environmental details, no other characters, pure character isolation for clean integration"
      }

      success_count = 0
      total_count = transparent_prompts.length

      transparent_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🎯 투명 배경 캐릭터 생성 #{index + 1}/#{total_count}"
        
        if generate_transparent_character(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 투명 배경 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 깨끗한 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'transparent', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n✨ 투명 배경 캐릭터 특징:"
        puts "  - 완전 투명 배경 (PNG)"
        puts "  - 받침대/구름/동물 친구들 모두 제거"
        puts "  - 순수 캐릭터만 단독 존재"
        puts "  - 히어로 섹션 배경과 자연스럽게 조화"
        puts "  - 부자연스러운 배치 문제 해결"
        puts "  - 깔끔한 통합을 위한 최적화"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

