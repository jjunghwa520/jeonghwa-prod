namespace :jeonghwa do
  desc "Force transparent background using Vertex AI with strong transparency prompts"
  task force_transparent: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎯 Vertex AI로 강력한 투명 배경 요청!"
    puts "💪 전략: 투명 배경 키워드 극대화"
    puts "🔧 모델: imagegeneration@006 + 투명 배경 파라미터"
    
    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    key_file_path = Rails.root.join('config', 'google_service_account.json')
    
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      token['access_token']
    end

    # 강력한 투명 배경 요청 함수
    def force_transparent_generation(access_token, project_id, location, prompt, filename)
      model_name = "imagegeneration@006"
      endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_name}:predict"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      # 투명 배경 강화 파라미터
      payload = {
        instances: [{ prompt: prompt }],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult",
          includeRaiReason: false,
          # 투명 배경 관련 파라미터 (실험적)
          guidance_scale: 20,  # 높은 가이던스로 프롬프트 강력 적용
          num_inference_steps: 50  # 더 정밀한 생성
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎯 강력 투명 배경 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'vertex_transparent')
          FileUtils.mkdir_p(output_dir)
          
          file_path = File.join(output_dir, "#{filename}.png")
          File.open(file_path, 'wb') { |file| file.write(image_data) }
          
          puts "✅ 성공: #{filename}.png (#{(image_data.size / 1024.0 / 1024.0).round(2)}MB)"
          return true
        else
          puts "❌ 실패: #{filename} - 이미지 데이터 없음"
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
      puts "🔑 액세스 토큰 획득 완료"
      
      # 극강 투명 배경 프롬프트들
      vertex_transparent_prompts = {
        "jeonghwa_vertex_transparent" => "3D figurine character floating in space with no background: Professional middle-aged female educator, soft East Asian features, gentle crescent eyes, short curly bob hair, bright blue blazer, black top, pearl necklace, black skirt, welcoming arms open gesture, holding teaching wand, TRANSPARENT BACKGROUND, NO BASE, NO PLATFORM, NO GROUND, NO ENVIRONMENT, FLOATING IN TRANSPARENT SPACE, PNG WITH ALPHA CHANNEL, REMOVE BACKGROUND COMPLETELY, ISOLATED CHARACTER ONLY, TRANSPARENT PNG FORMAT",
        
        "jeonghwa_vertex_clean" => "Clean 3D character with zero background elements: Female educator with East Asian face, almond eyes, curly bob hair, blue blazer, teaching pose, COMPLETELY TRANSPARENT BACKGROUND, NO VISIBLE BACKGROUND, ALPHA TRANSPARENCY, PNG FORMAT, REMOVE ALL BACKGROUND, CHARACTER ONLY, FLOATING ON NOTHING, TRANSPARENT SPACE AROUND CHARACTER"
      }

      success_count = 0
      total_count = vertex_transparent_prompts.length

      vertex_transparent_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🎯 Vertex AI 투명 배경 생성 #{index + 1}/#{total_count}"
        
        if force_transparent_generation(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 Vertex AI 투명 배경 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 Vertex AI 투명 캐릭터들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'vertex_transparent', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

