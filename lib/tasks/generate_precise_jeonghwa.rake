namespace :jeonghwa do
  desc "Generate precise Jeonghwa character matching reference image exactly"
  task generate_precise: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🎯 참고 이미지 정밀 분석 기반 정화 캐릭터 생성!"
    puts "📋 극도로 세밀한 특징 반영: 얼굴형, 헤어라인, 미소, 의상 디테일"
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

    # 정밀 분석 기반 정화 캐릭터 생성 함수
    def generate_precise_jeonghwa(access_token, project_id, location, prompt, filename)
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
          
          output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'precise')
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
      
      # 참고 이미지 정밀 분석 기반 극도로 세밀한 프롬프트
      precise_prompts = {
        "jeonghwa_precise_main" => "Educational illustration of a professional middle-aged female educator with specific East Asian facial characteristics: round soft face shape with full cheeks, gentle almond-shaped dark brown eyes with slight epicanthic fold, warm genuine smile showing small white teeth, short curly bob haircut in rich dark brown color with natural waves framing the face and covering the ears, wearing bright royal blue professional blazer with structured shoulders and lapels over black crew neck top, small pearl necklace with evenly spaced white pearls, black knee-length A-line skirt, holding colorful educational books and teaching materials in both hands, full body standing pose with confident but approachable posture, 3D cartoon illustration style similar to Pixar animation with soft lighting and warm color palette, isolated on transparent background with no environmental elements, pedagogical character design for children's educational platform, friendly and trustworthy educator personality with maternal warmth",
        
        "jeonghwa_precise_teaching" => "Educational poster featuring an enthusiastic middle-aged female instructor with round soft East Asian face, gentle almond eyes with warm expression, short curly bob hairstyle in dark brown with natural texture, dressed in bright blue professional cardigan with structured design over black blouse, small pearl necklace visible at neckline, black professional skirt, demonstrating with animated hand gestures while holding an open colorful storybook, full body dynamic teaching pose with one hand raised expressively, warm encouraging smile with visible teeth, 3D cartoon mascot style with soft realistic lighting, completely transparent background, children's learning app character design with maternal educator aesthetic",
        
        "jeonghwa_precise_sitting" => "Classroom educational material showing a nurturing middle-aged female storyteller with round gentle East Asian facial features, almond-shaped eyes with kind expression, short wavy bob hair in rich dark brown color, sitting comfortably in cross-legged pose, wearing soft blue professional jacket with structured collar over black top, small white pearl necklace, black skirt arranged modestly, reading from a colorful picture book with expressive caring face and warm genuine smile, full body illustration in relaxed seated position with good posture, 3D cartoon character design with warm lighting, isolated on transparent background, pedagogical illustration for educational materials emphasizing maternal warmth and professionalism",
        
        "jeonghwa_precise_welcome" => "Educational mascot design of a welcoming middle-aged female mentor with specific East Asian features: round soft face with full cheeks, gentle almond eyes with warm sparkle, short curly bob haircut in dark brown with natural waves, arms open wide in friendly greeting gesture, wearing professional bright blue blazer with structured design over black crew neck top, small pearl necklace with white round pearls, black A-line skirt, bright warm smile showing small white teeth, holding magical teaching wand with colorful sparkles, full body standing pose with welcoming stance and confident posture, 3D cartoon illustration style with Pixar-quality rendering, transparent background with no setting, classroom poster artwork quality with emphasis on approachable maternal educator personality"
      }

      success_count = 0
      total_count = precise_prompts.length

      precise_prompts.each_with_index do |(filename, prompt), index|
        puts "━" * 70
        puts "🎯 정밀 분석 정화 캐릭터 생성 #{index + 1}/#{total_count}"
        
        if generate_precise_jeonghwa(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 정밀 분석 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'precise', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎯 참고 이미지 정밀 분석 반영:"
        puts "  - 둥근 부드러운 얼굴형 (풍만한 볼)"
        puts "  - 아몬드형 짙은 갈색 눈 (약간의 쌍꺼풀)"
        puts "  - 짧은 곱슬 단발 (짙은 갈색, 자연스러운 웨이브)"
        puts "  - 밝은 로얄블루 재킷 (구조적 어깨라인)"
        puts "  - 검은색 크루넥 상의 + 작은 진주 목걸이"
        puts "  - 검은색 A라인 무릎길이 치마"
        puts "  - 따뜻하고 진정성 있는 미소 (작은 하얀 치아)"
        puts "  - 전문적이면서도 모성적인 분위기"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

