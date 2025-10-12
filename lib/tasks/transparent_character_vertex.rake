namespace :hero do
  desc "Generate transparent PNG character illustrations using Vertex AI"
  task generate_transparent_characters: :environment do
    require 'net/http'
    require 'json'
    require 'base64'

    # Google Cloud 설정
    project_id = "gen-lang-client-0492798913"
    location = "us-central1"
    
    # 서비스 계정 키 파일 경로
    key_file_path = Rails.root.join('config', 'google_service_account.json')
    
    unless File.exist?(key_file_path)
      puts "❌ 서비스 계정 키 파일을 찾을 수 없습니다: #{key_file_path}"
      next
    end

    # 액세스 토큰 생성
    def get_access_token(key_file_path)
      require 'googleauth'
      
      scope = ['https://www.googleapis.com/auth/cloud-platform']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      authorizer.fetch_access_token!['access_token']
    end

    # 이미지 생성 함수
    def generate_image(access_token, project_id, location, prompt, filename)
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/imagen-3.0-generate-001:predict")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      request.body = {
        instances: [
          {
            prompt: prompt
          }
        ],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult"
        }
      }.to_json
      
      puts "🎨 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt}"
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          # 이미지 저장
          output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'transparent_characters')
          FileUtils.mkdir_p(output_dir)
          
          File.open(File.join(output_dir, filename), 'wb') do |file|
            file.write(image_data)
          end
          
          puts "✅ 성공: #{filename}"
          return true
        else
          puts "❌ 실패: #{filename} - 이미지 데이터 없음"
          puts "응답: #{result}"
          return false
        end
      else
        puts "❌ 실패: #{filename} - HTTP #{response.code}"
        puts "응답: #{response.body}"
        return false
      end
    rescue => e
      puts "❌ 오류: #{filename} - #{e.message}"
      return false
    end

    begin
      access_token = get_access_token(key_file_path)
      puts "🔑 액세스 토큰 획득 완료"
      
      # 투명 배경 캐릭터들 생성 (배경 제거 요청 포함)
      transparent_characters = {
        # 메인 캐릭터 - 책을 읽는 아이 (투명 배경)
        "main_child_reading.png" => "A cute Korean child character sitting and reading a book, 3D cartoon style, Pixar animation quality, friendly smile, colorful casual clothes, isolated on transparent background, no background, cutout style",
        
        # 손 흔드는 캐릭터
        "child_waving.png" => "A cheerful child character waving hello with both hands, 3D cartoon style, big smile, colorful t-shirt and jeans, isolated on transparent background, no background, cutout style",
        
        # 점프하는 캐릭터
        "child_jumping.png" => "A happy child character jumping with joy, arms up in the air, 3D cartoon style, excited expression, bright clothes, isolated on transparent background, no background, cutout style",
        
        # 책을 들고 있는 캐릭터
        "child_holding_book.png" => "A smiling child character holding a colorful storybook, 3D cartoon style, proud expression, school clothes, isolated on transparent background, no background, cutout style",
        
        # 여자아이 캐릭터
        "girl_character.png" => "A cute girl character with pigtails, wearing a colorful dress, 3D cartoon style, sweet smile, isolated on transparent background, no background, cutout style",
        
        # 남자아이 캐릭터  
        "boy_character.png" => "A friendly boy character with short hair, wearing casual shirt and shorts, 3D cartoon style, cheerful expression, isolated on transparent background, no background, cutout style"
      }

      success_count = 0
      total_count = transparent_characters.length

      transparent_characters.each do |filename, prompt|
        if generate_image(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 조정 (할당량 고려)
        sleep(3)
      end

      puts "\n🎉 투명 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts e.backtrace.first(5)
    end
  end
end

