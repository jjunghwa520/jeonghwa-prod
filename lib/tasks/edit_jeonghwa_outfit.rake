namespace :jeonghwa_outfit do
  desc "Edit Jeonghwa character outfit using Gemini 2.5 Flash Image (Nano Banana)"
  task edit: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'fileutils'

    puts "👗 나노바나나로 정화 캐릭터 의상 편집"
    puts "🎯 기존 캐릭터 일관성 유지 + 의상만 변경"

    # Gemini API 키 확인
    api_key = ENV['GEMINI_API_KEY']
    if api_key.nil? || api_key.empty?
      puts "❌ GEMINI_API_KEY가 설정되지 않았습니다!"
      return
    end

    puts "✅ Gemini API 키 확인 완료"

    # 원본 정화 캐릭터 이미지 읽기
    base_image_path = Rails.root.join('public', 'images', 'refined', 'jeonghwa_refined_isnet-general-use.png')
    unless File.exist?(base_image_path)
      puts "❌ 원본 정화 이미지 없음: #{base_image_path}"
      return
    end

    image_data = Base64.strict_encode64(File.read(base_image_path))
    puts "📸 원본 정화 이미지 로드 완료"

    # 나노바나나 API 엔드포인트
    uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-goog-api-key'] = api_key

    # 의상 편집 프롬프트 (기존 캐릭터 유지)
    edit_prompt = "Edit this character image to change only the clothing while keeping everything else exactly the same (face, hair, pose, style, background). Change the blue cardigan and black outfit to an elegant navy blue A-line dress with 3/4 sleeves, keeping the same pearl necklace. Maintain the exact same cartoon/anime art style, facial features, hair style, pose, and transparent background. Only modify the clothing, nothing else should change."

    request_body = {
      contents: [{
        parts: [
          {
            text: edit_prompt
          },
          {
            inlineData: {
              mimeType: "image/png",
              data: image_data
            }
          }
        ]
      }],
      generationConfig: {
        aspectRatio: "1:1",
        safetyFilterLevel: "block_some",
        personGeneration: "allow_adult"
      }
    }

    request.body = request_body.to_json

    puts "\n👗 나노바나나로 의상 편집 중..."
    response = http.request(request)
    puts "응답: #{response.code} #{response.message}"

    if response.code == '200'
      result = JSON.parse(response.body)
      
      if result['candidates'] && result['candidates'][0] && 
         result['candidates'][0]['content'] && 
         result['candidates'][0]['content']['parts']
        
        parts = result['candidates'][0]['content']['parts']
        image_part = parts.find { |part| part['inlineData'] && part['inlineData']['mimeType']&.include?('image') }
        
        if image_part && image_part['inlineData']
          edited_image_data = image_part['inlineData']['data']
          
          # 편집된 이미지 저장
          output_path = Rails.root.join('app', 'assets', 'images', 'generated', 'jeonghwa_dress_edited.png')
          FileUtils.mkdir_p(File.dirname(output_path))
          
          File.binwrite(output_path, Base64.decode64(edited_image_data))
          
          puts "✅ 의상 편집 완료: #{output_path}"
          puts "📏 파일 크기: #{(File.size(output_path) / 1024.0).round(1)}KB"
          puts "💡 기존 캐릭터의 얼굴, 헤어스타일, 포즈는 그대로 유지하고 의상만 변경됨"
          
        else
          puts "❌ 편집된 이미지 데이터 없음"
          puts "응답 구조: #{result}"
        end
      else
        puts "❌ 예상과 다른 응답 구조: #{result}"
      end
    else
      puts "❌ API 오류: #{response.body}"
    end

    puts "\n🎉 나노바나나 의상 편집 작업 완료!"
  end
end

