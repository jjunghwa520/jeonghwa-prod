namespace :jeonghwa do
  desc "Generate Korean-featured Jeonghwa character with strategic prompting"
  task generate_korean: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🇰🇷 한국인 정화 대표 캐릭터 생성 시작!"
    puts "📋 특징: 동양인 얼굴, 곱슬 단발, 파란 카디건, 검은 상의/치마"
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

    # 한국인 정화 캐릭터 생성 함수
    def generate_korean_jeonghwa(access_token, project_id, location, prompt, filename)
      model_name = "imagegeneration@006"
      endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_name}:predict"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      payload = {
        instances: [{ prompt: prompt }],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult",
          includeRaiReason: false
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎨 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'korean')
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
      puts "❌예외: #{filename} - #{e.message}"
      return false
    end

    begin
      access_token = get_access_token(key_file_path)
      puts "🔑 액세스 토큰 획득 완료\n"
      
      # 한국인 특징을 안전하게 표현하는 전략적 프롬프트
      korean_prompts = {
        "jeonghwa_korean_main" => "Educational illustration of a professional 40-year-old female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut with dark brown color, wearing bright blue blazer over black top with pearl necklace and black skirt, warm friendly smile with round face, holding colorful educational books and teaching materials, full body standing pose with confident welcoming posture, 3D cartoon illustration style similar to Pixar animation, isolated on transparent background, pedagogical character design for children's educational platform in East Asian context",
        
        "jeonghwa_korean_teaching" => "Educational poster featuring an enthusiastic 40-year-old female instructor with East Asian appearance, almond eyes and gentle facial features, short curly bob hairstyle in dark brown, dressed in sky blue professional cardigan over black blouse with necklace and dark skirt, demonstrating with animated hand gestures while holding an open storybook, full body dynamic teaching pose with confident expression, 3D cartoon mascot style, completely transparent background, children's learning app character design with East Asian cultural context",
        
        "jeonghwa_korean_sitting" => "Classroom educational material showing a 40-year-old female storyteller with East Asian features, almond-shaped eyes and warm expression, short wavy bob hair in dark brown color, sitting comfortably in cross-legged pose, wearing soft blue professional jacket over black top with pearl necklace, reading from a colorful picture book with expressive face and warm smile, full body illustration in relaxed seated pose, 3D cartoon character design, isolated on transparent background, pedagogical illustration for educational materials",
        
        "jeonghwa_korean_welcome" => "Educational mascot design of a welcoming 40-year-old female mentor with East Asian facial characteristics, almond eyes with kind expression, short curly bob haircut in dark brown, arms open wide in friendly greeting gesture, wearing professional blue blazer over black top with necklace and black skirt, bright warm smile with confident eyes, holding magical teaching wand with sparkles, full body standing pose with professional stance, 3D cartoon illustration style, transparent background, classroom poster artwork quality"
      }

      success_count = 0
      total_count = korean_prompts.length

      korean_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🇰🇷 한국인 정화 대표 생성 #{index + 1}/#{total_count}"
        
        if generate_korean_jeonghwa(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 한국인 정화 대표 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'korean', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🇰🇷 한국인 특징 반영:"
        puts "  - 동양인/한국인 얼굴 특징 (아몬드 모양 눈)"
        puts "  - 짧은 곱슬/웨이브 단발머리 (짙은 갈색)"
        puts "  - 파란색 카디건/재킷"
        puts "  - 검은색 상의 + 진주 목걸이"
        puts "  - 검은색 치마"
        puts "  - 40대 전문 교육자 분위기"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

