namespace :jeonghwa do
  desc "Generate Jeonghwa character using proper Gemini 2.5 Flash Image (Nano Banana) API"
  task generate_gemini_nano_banana_fixed: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🍌 진짜 나노바나나 API 사용 - Gemini 2.5 Flash Image!"
    puts "🎨 특징: 세계 최고 평점 이미지 편집 모델"
    puts "⚡ 기능: 텍스트-이미지 생성, 이미지 편집, 다중 합성"
    
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

    # Gemini 2.5 Flash Image 생성 함수 (OAuth 토큰 사용)
    def generate_gemini_nano_banana(access_token, prompt, filename)
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
      
      puts "\n🍌 나노바나나 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        # Gemini API 응답 구조에서 이미지 데이터 추출
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano')
              FileUtils.mkdir_p(output_dir)
              
              file_path = File.join(output_dir, "#{filename}.png")
              File.open(file_path, 'wb') { |file| file.write(image_data) }
              
              puts "✅ 성공: #{filename}.png (#{(image_data.size / 1024.0 / 1024.0).round(2)}MB)"
              return true
            end
          end
          
          puts "❌ 실패: #{filename} - 이미지 데이터 없음 (텍스트 응답만 있음)"
          if result['candidates'][0]['content']['parts'][0]['text']
            puts "📄 응답: #{result['candidates'][0]['content']['parts'][0]['text'][0..200]}..."
          end
          return false
        else
          puts "❌ 실패: #{filename} - 예상치 못한 응답 구조"
          puts "📄 응답: #{result.inspect[0..500]}..."
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
      
      # 진짜 나노바나나 최적화 프롬프트 (이미지 생성 특화)
      gemini_nano_prompts = {
        "jeonghwa_gemini_main" => "Generate a cute 3D figurine-style character: A professional middle-aged female educator with round soft East Asian facial features, gentle almond-shaped dark eyes, short curly bob hairstyle in rich dark brown color, wearing bright royal blue blazer over black crew neck top, small white pearl necklace, black A-line knee-length skirt, warm genuine smile showing small teeth, holding colorful educational books in welcoming pose, full body standing position, 3D collectible toy aesthetic with smooth surfaces and adorable proportions, soft pastel lighting, clean white background, high-quality figurine rendering for educational mascot design",
        
        "jeonghwa_gemini_teaching" => "Create a charming 3D figurine: An enthusiastic female instructor with round gentle East Asian face, kind almond eyes with warm expression, short wavy bob hair in dark brown, bright blue professional cardigan over black blouse, pearl necklace detail, dark skirt, animated teaching gesture with one hand raised holding colorful storybook, dynamic pose showing movement, 3D toy character style with cute proportions, soft realistic lighting, isolated white background, collectible figurine quality for children's educational content",
        
        "jeonghwa_gemini_welcome" => "Design an adorable 3D figurine: A welcoming middle-aged female mentor with soft round East Asian features, gentle almond-shaped eyes with sparkle, short curly bob hairstyle in rich brown, arms open wide in friendly greeting gesture, wearing professional bright blue blazer over black top, small pearl necklace, black A-line skirt, joyful smile with warm expression, holding magical teaching wand with colorful sparkle effects, full body welcoming stance, 3D collectible toy aesthetic with smooth surfaces, pastel color palette, clean background"
      }

      success_count = 0
      total_count = gemini_nano_prompts.length

      gemini_nano_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🍌 Gemini 나노바나나 생성 #{index + 1}/#{total_count}"
        
        if generate_gemini_nano_banana(access_token, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 (Gemini API 제한 고려)
        sleep(3) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 진짜 나노바나나 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🍌 진짜 나노바나나 (Gemini 2.5 Flash Image) 특징:"
        puts "  - 세계 최고 평점 이미지 편집 모델"
        puts "  - SynthID 디지털 워터마크 포함"
        puts "  - 고품질 텍스트 렌더링 지원"
        puts "  - 반복적 개선 가능"
        puts "  - 다중 이미지 합성 지원"
        puts "  - 3D 피규어 스타일 최적화"
      else
        puts "\n💡 문제 해결 방법:"
        puts "  1. Google Service Account 권한 확인"
        puts "  2. Gemini API 활성화 확인"
        puts "  3. 프롬프트 정책 위반 여부 확인"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

