namespace :jeonghwa do
  desc "Develop and refine the welcome character using Nano Banana image editing"
  task develop_welcome: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎨 나노바나나 이미지 편집으로 3번 캐릭터 발전시키기!"
    puts "✨ 기능: 기존 이미지 수정, 세부 디테일 개선"
    puts "🎯 목표: 더 정화다운, 더 푸근한, 더 한국적인"
    
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

    # 나노바나나 이미지 편집 함수
    def edit_with_nano_banana(access_token, edit_prompt, filename)
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}"
      
      # 기존 이미지를 기반으로 편집하는 프롬프트
      payload = {
        contents: [
          {
            parts: [
              {
                text: edit_prompt
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.8,  # 창의성 약간 증가
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192
        }
      }
      
      request.body = payload.to_json
      
      puts "\n✨ 나노바나나 편집 중: #{filename}"
      puts "📝 편집 프롬프트: #{edit_prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        # Gemini API 응답 구조에서 이미지 데이터 추출
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          parts = result['candidates'][0]['content']['parts']
          
          parts.each do |part|
            if part['inlineData'] && part['inlineData']['data']
              image_data = Base64.decode64(part['inlineData']['data'])
              
              output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'developed')
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
      
      # 3번 캐릭터를 더욱 발전시키는 편집 프롬프트들
      development_prompts = {
        "jeonghwa_v2_enhanced" => "Enhance this 3D figurine character to be more Korean-looking: Make the face rounder and softer with fuller cheeks, enhance the warm motherly smile to show more genuine happiness, make the eyes slightly smaller and more almond-shaped with gentle crinkles showing kindness, adjust the hair to be more naturally curly with soft waves, make the blue blazer more structured and professional, add subtle rosy cheeks for warmth, ensure the pearl necklace is more visible and elegant, improve the overall proportions to be more nurturing and approachable, maintain the 3D collectible toy aesthetic but with enhanced Korean facial features and maternal warmth",
        
        "jeonghwa_v2_expression" => "Refine this character's facial expression: Make the smile more genuine and warm, showing the kind of joy that comes from working with children, add gentle laugh lines around the eyes to show experience and wisdom, make the eyes sparkle with enthusiasm for education, adjust the eyebrows to be softer and more expressive, enhance the overall facial expression to convey trustworthiness and maternal care, keep the professional appearance but add more personality and warmth to make parents feel comfortable leaving their children with this educator",
        
        "jeonghwa_v2_posture" => "Improve this character's welcoming posture: Make the arm gesture more natural and inviting, as if she's genuinely excited to meet new students and parents, adjust the body language to be more open and approachable, enhance the way she holds the teaching materials to show expertise and care, make the overall stance more confident yet humble, showing both professional competence and personal warmth, ensure the pose conveys the message 'I'm here to help your child learn and grow'",
        
        "jeonghwa_v2_details" => "Add more Korean cultural details and educational elements: Enhance the clothing to reflect Korean professional style while maintaining the blue blazer, add subtle educational accessories like a name tag or teaching badge, include small details that suggest experience in early childhood education, make the books she's holding more colorful and child-friendly, add gentle lighting that creates a warm, welcoming atmosphere, ensure all details support the image of a trusted Korean educator who specializes in children's storytelling and education"
      }

      success_count = 0
      total_count = development_prompts.length

      development_prompts.each_with_index do |(filename, edit_prompt), index|
        puts "━" * 70
        puts "✨ 3번 캐릭터 발전 #{index + 1}/#{total_count}"
        
        if edit_with_nano_banana(access_token, edit_prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(4) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 3번 캐릭터 발전 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 발전된 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'developed', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🚀 발전된 특징들:"
        puts "  - 더 한국적인 얼굴 특징"
        puts "  - 더 따뜻하고 진정성 있는 표정"
        puts "  - 더 자연스럽고 환영하는 자세"
        puts "  - 더 전문적인 교육자 디테일"
        puts "  - 나노바나나 이미지 편집 기능 활용"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

