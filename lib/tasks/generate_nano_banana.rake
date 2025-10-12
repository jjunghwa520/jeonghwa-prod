namespace :jeonghwa do
  desc "Generate Jeonghwa character using Google Nano Banana 3D figurine style"
  task generate_nano_banana: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🍌 구글 나노바나나 3D 피규어 스타일 정화 캐릭터 생성!"
    puts "🎨 특징: 3D 피규어, 일관된 캐릭터, 귀여운 스타일"
    puts "🔧 프로젝트 ID: #{project_id}"
    puts "🌍 위치: #{location}"
    
    # 서비스 계정 키 파일 경로
    key_file_path = Rails.root.join('config', 'google_service_account.json')

    # 액세스 토큰 생성 함수
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      token['access_token']
    end

    # 나노바나나 스타일 정화 캐릭터 생성 함수
    def generate_nano_banana_character(access_token, project_id, location, prompt, filename)
      # 나노바나나 모델 (3D 피규어 특화)
      model_name = "imagegeneration@006"
      endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_name}:predict"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      # 나노바나나 3D 피규어 최적화 설정
      payload = {
        instances: [{ prompt: prompt }],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult",
          includeRaiReason: false,
          # 3D 피규어 스타일 강화
          guidance_scale: 15,  # 높은 가이던스로 일관성 향상
          num_inference_steps: 50  # 더 정밀한 생성
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🍌 나노바나나 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'nano_banana')
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
      puts "🔑 액세스 토큰 획득 완료\n"
      
      # 나노바나나 3D 피규어 스타일 프롬프트 (일관성 최적화)
      nano_banana_prompts = {
        "jeonghwa_nano_main" => "A cute 3D figurine character of a professional middle-aged female educator, round soft face with gentle almond eyes, short curly bob hairstyle in dark brown, wearing bright blue blazer over black top with small pearl necklace, black A-line skirt, warm friendly smile, holding colorful books, standing pose with welcoming gesture, 3D toy figurine style like collectible character, soft pastel colors, clean white background, high quality 3D rendering with smooth surfaces and adorable proportions, educational mascot design",
        
        "jeonghwa_nano_teaching" => "A charming 3D figurine of an enthusiastic female instructor, round East Asian face with kind almond-shaped eyes, short wavy bob hair in rich brown, bright blue professional cardigan over black blouse, pearl necklace detail, dark skirt, animated teaching gesture with raised hand holding open storybook, 3D collectible toy style with cute proportions, soft lighting and pastel color palette, isolated on white background, adorable educational character figurine",
        
        "jeonghwa_nano_sitting" => "A delightful 3D figurine showing a nurturing female storyteller, gentle round face with warm almond eyes, curly short bob hairstyle in dark brown, sitting cross-legged in comfortable pose, wearing soft blue jacket over black top, small white pearls around neck, black skirt, reading colorful picture book with expressive face, 3D toy character style with smooth surfaces, cute and friendly proportions, clean background, collectible figurine aesthetic",
        
        "jeonghwa_nano_welcome" => "An adorable 3D figurine of a welcoming female mentor, soft round East Asian features with gentle almond eyes, short curly bob hair in dark brown, arms open wide in greeting pose, bright blue blazer over black crew neck top, pearl necklace accent, black A-line skirt, joyful smile with sparkling eyes, holding magical teaching wand with colorful effects, 3D collectible character style with cute proportions, pastel colors, white background, high-quality figurine rendering"
      }

      success_count = 0
      total_count = nano_banana_prompts.length

      nano_banana_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🍌 나노바나나 3D 피규어 생성 #{index + 1}/#{total_count}"
        
        if generate_nano_banana_character(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 나노바나나 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'nano_banana', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🍌 나노바나나 3D 피규어 특징:"
        puts "  - 3D 피규어/컬렉터블 토이 스타일"
        puts "  - 일관된 캐릭터 디자인"
        puts "  - 귀여운 비율과 부드러운 표면"
        puts "  - 파스텔 컬러와 깔끔한 배경"
        puts "  - 교육용 마스코트 최적화"
        puts "  - 참고 이미지 특징 반영 (둥근 얼굴, 곱슬 단발, 파란 카디건)"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

