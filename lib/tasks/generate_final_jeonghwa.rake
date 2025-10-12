namespace :jeonghwa do
  desc "Generate final Jeonghwa character based on two reference images"
  task generate_final: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎯 두 참고 이미지 기반 최종 정화 캐릭터 생성!"
    puts "📸 참고1: 교육자 + 동물 친구들 + 받침대"
    puts "📸 참고2: 마법 지팡이 + 구름 받침대 + 초승달 눈"
    puts "🍌 나노바나나 최고급 품질로 생성"
    
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

    # 최종 정화 캐릭터 생성 함수
    def generate_final_jeonghwa(access_token, prompt, filename)
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
      
      puts "\n🎯 최종 캐릭터 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'final')
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
      
      # 두 참고 이미지의 장점을 결합한 최종 프롬프트들
      final_prompts = {
        "jeonghwa_final_main" => "Create the ultimate 3D figurine character for Jeonghwa's Library: A professional middle-aged female educator with soft East Asian facial features, gentle crescent-shaped eyes that curve downward when smiling (showing pure warmth like the second reference), round soft face with rosy cheeks, short curly bob hairstyle in rich dark brown with natural waves, wearing bright royal blue professional blazer over black top with elegant white pearl necklace, black A-line skirt, arms open wide in natural welcoming gesture, holding a magical teaching wand with colorful sparkles (like second reference), standing on a soft cloud-like base platform (inspired by second reference), surrounded by small cute animal friends including tiny bears and rabbits (like first reference), 3D collectible toy aesthetic with smooth surfaces and adorable proportions, soft pastel lighting, clean background, educational mascot design that perfectly represents Jeonghwa's Library brand",
        
        "jeonghwa_final_welcome" => "Design the perfect 3D figurine for Jeonghwa's Library brand: A warm middle-aged female educator with incredibly gentle East Asian eyes (crescent-shaped when smiling, absolutely no sharpness), round loving face with soft features, short wavy bob hair in dark brown, wearing professional bright blue blazer over black crew neck top, white pearl necklace, black skirt, arms positioned in the most natural and loving welcome pose, holding magical educational wand that creates rainbow sparkles and floating books, standing on a decorative cloud platform with soft edges, small educational toys and cute animal figures around the base (bears, rabbits, books), 3D toy character style with maximum emphasis on trust and maternal warmth, perfect for children's educational platform branding",
        
        "jeonghwa_final_perfect" => "Generate the definitive Jeonghwa character combining both reference images: A professional 40-year-old female educator with soft round East Asian facial features, the gentlest possible crescent eyes that sparkle with joy (no trace of sternness), natural rosy cheeks, short curly bob hairstyle in warm brown, wearing structured bright blue blazer over black top, elegant pearl necklace, black A-line skirt, one hand in welcoming gesture and other holding a magical teaching wand with rainbow effects, standing confidently on a soft pastel cloud base, surrounded by tiny educational elements and cute animal companions, 3D collectible figurine style with perfect proportions, warm lighting that enhances the caring expression, isolated background, ultimate educational mascot design"
      }

      success_count = 0
      total_count = final_prompts.length

      final_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🎯 최종 정화 캐릭터 생성 #{index + 1}/#{total_count}"
        
        if generate_final_jeonghwa(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 최종 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 최종 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'final', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎯 두 참고 이미지 결합 특징:"
        puts "  - 첫 번째 참고: 교육적 분위기 + 동물 친구들"
        puts "  - 두 번째 참고: 마법 지팡이 + 초승달 눈 + 구름 받침대"
        puts "  - 완벽한 3D 피규어 스타일"
        puts "  - 정화의 서재 브랜드 완벽 매칭"
        puts "  - 아이들과 부모 모두 신뢰할 수 있는 캐릭터"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

