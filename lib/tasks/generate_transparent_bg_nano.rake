namespace :jeonghwa do
  desc "Generate same character with explicit transparent background using Nano Banana"
  task generate_transparent_bg: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🍌 나노바나나로 투명 배경 명시 생성!"
    puts "🎯 목표: 동일한 캐릭터 + 투명 배경 명시적 요청"
    puts "✨ 프롬프트에 투명 배경 강력 요청"
    
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

    # 투명 배경 명시 생성 함수
    def generate_with_transparent_bg(access_token, prompt, filename)
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
          temperature: 0.6,  # 일관성을 위해 낮은 온도
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🍌 투명 배경 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'transparent_bg')
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
      
      # 투명 배경 강력 요청 프롬프트들 (캐릭터는 동일하게)
      transparent_prompts = {
        "jeonghwa_transparent_welcome" => "Generate a 3D figurine character with completely transparent background: A welcoming middle-aged female educator with soft round East Asian features, gentle almond-shaped eyes with sparkle, short curly bob hairstyle in rich brown, arms open wide in friendly greeting gesture, wearing professional bright blue blazer over black top, small pearl necklace, black A-line skirt, joyful smile with warm expression, holding magical teaching wand with colorful sparkle effects, full body welcoming stance, 3D collectible toy aesthetic with smooth surfaces, COMPLETELY TRANSPARENT BACKGROUND, NO BACKGROUND ELEMENTS, NO BASE, NO PLATFORM, NO ENVIRONMENTAL DETAILS, ISOLATED CHARACTER ONLY ON TRANSPARENT PNG BACKGROUND, remove all background completely, transparent background only",
        
        "jeonghwa_transparent_main" => "Create a 3D figurine with absolutely no background: A professional middle-aged female educator with round soft East Asian facial features, gentle almond-shaped dark eyes, short curly bob hairstyle in rich dark brown color, wearing bright royal blue blazer over black crew neck top, small white pearl necklace, black A-line knee-length skirt, warm genuine smile, holding colorful educational books in welcoming pose, full body standing position, 3D collectible toy aesthetic, TRANSPARENT BACKGROUND ONLY, NO BACKGROUND WHATSOEVER, COMPLETELY ISOLATED CHARACTER, REMOVE ALL BACKGROUND ELEMENTS, PURE TRANSPARENT PNG",
        
        "jeonghwa_transparent_teaching" => "Design a 3D figurine on transparent background: An enthusiastic female instructor with round gentle East Asian face, kind almond eyes with warm expression, short wavy bob hair in dark brown, bright blue professional cardigan over black blouse, pearl necklace detail, dark skirt, animated teaching gesture with one hand raised holding colorful storybook, 3D toy character style, ABSOLUTELY TRANSPARENT BACKGROUND, NO BASE, NO PLATFORM, NO SURROUNDING OBJECTS, ISOLATED CHARACTER FLOATING ON TRANSPARENT PNG BACKGROUND"
      }

      success_count = 0
      total_count = transparent_prompts.length

      transparent_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🍌 투명 배경 명시 생성 #{index + 1}/#{total_count}"
        
        if generate_with_transparent_bg(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 투명 배경 명시 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 투명 배경 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'transparent_bg', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🍌 나노바나나 투명 배경 특징:"
        puts "  - 투명 배경 명시적 요청"
        puts "  - 캐릭터는 동일하게 유지"
        puts "  - 모든 배경 요소 완전 제거"
        puts "  - 순수 PNG 투명 배경"
        puts "  - 히어로 섹션과 자연스러운 조화"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

