namespace :jeonghwa do
  desc "Generate new Jeonghwa character for hero section using Vertex AI"
  task generate_character: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🎨 정화 캐릭터 생성 시작!"
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

    # 정화 캐릭터 생성 함수
    def generate_jeonghwa_character(access_token, project_id, location, prompt, filename)
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
      puts "📝 프롬프트: #{prompt[0..100]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('public', 'images', 'jeonghwa')
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
      
      # 정화 캐릭터 기반 새로운 캐릭터 프롬프트들
      jeonghwa_characters = {
        "jeonghwa_hero_main" => "Educational illustration of a friendly professional woman character with curly brown hair and warm smile, wearing a blue blazer over black dress with pearl necklace, holding a magical glowing storybook and a golden pen, standing confidently in a bright library setting, 3D cartoon style with Pixar-quality rendering, warm lighting, storybook publishing company mascot design, Korean features, approachable and trustworthy appearance, children's education theme",
        
        "jeonghwa_hero_waving" => "Educational mascot character design of a cheerful woman with curly brown hair waving hello with her right hand while holding a colorful children's book in her left hand, wearing professional blue jacket and black outfit, 3D cartoon illustration style, bright and welcoming expression, library background with floating books, Pixar-quality animation style, educational content creator theme",
        
        "jeonghwa_hero_reading" => "Classroom poster illustration of a warm and friendly female educator character with curly brown hair sitting cross-legged while reading a magical storybook to invisible children, wearing blue blazer and professional attire, surrounded by floating colorful books and sparkles, 3D rendered cartoon style, educational publishing mascot design, cozy reading corner atmosphere",
        
        "jeonghwa_hero_writing" => "Educational character illustration of a professional woman with curly brown hair and kind smile, sitting at a wooden desk writing in a large storybook with a golden quill pen, wearing blue jacket over dark dress, surrounded by floating paper airplanes made of book pages, warm library lighting, 3D cartoon style for children's educational materials",
        
        "jeonghwa_logo_character" => "Simple mascot character design of a friendly woman with curly brown hair for logo use, wearing blue blazer, holding a book and pen, clean white background, 3D cartoon style, educational brand mascot, simplified design suitable for small sizes, professional yet approachable appearance"
      }

      success_count = 0
      total_count = jeonghwa_characters.length

      jeonghwa_characters.each_with_index do |(filename, prompt), index|
        puts "━" * 60
        puts "📚 정화 캐릭터 생성 #{index + 1}/#{total_count}"
        
        if generate_jeonghwa_character(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 (할당량 고려)
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 60
      puts "🎉 정화 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🔗 사용법:"
        puts "  <img src=\"/images/jeonghwa/파일명.png\">"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

