namespace :hero do
  desc "Generate hero section character and book illustrations using Vertex AI"
  task generate_characters: :environment do
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
          output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'hero_characters')
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
      
      # 히어로 섹션용 캐릭터 및 요소들 생성
      hero_elements = {
        # 메인 캐릭터 - 책을 읽는 아이
        "main_character.jpg" => "A cheerful Korean child character in 3D cartoon style, sitting cross-legged and reading a magical glowing storybook, wearing casual colorful clothes, friendly smile, soft lighting, Pixar animation style, warm and inviting atmosphere",
        
        # 플로팅 책들
        "floating_book_1.jpg" => "A magical floating storybook with golden pages and sparkles, 3D rendered, fairy tale style, soft pastel colors, dreamy atmosphere",
        
        "floating_book_2.jpg" => "An open children's book with colorful illustrations floating in the air, 3D cartoon style, rainbow colors, magical sparkles around it",
        
        "floating_book_3.jpg" => "A stack of colorful children's books floating with magical particles, 3D rendered, warm lighting, storybook aesthetic",
        
        # 동화 요소들
        "fairy_tale_elements.jpg" => "Floating fairy tale elements like stars, hearts, musical notes, and magic sparkles in 3D cartoon style, pastel colors, dreamy atmosphere",
        
        # 배경 캐릭터들
        "background_character_1.jpg" => "A cute 3D cartoon child character waving hello, Korean features, colorful casual clothes, friendly expression, Pixar style",
        
        "background_character_2.jpg" => "A happy 3D cartoon child character holding a storybook, diverse features, bright colors, joyful expression, animation style",
        
        # 마법의 요소들
        "magic_elements.jpg" => "Magical floating elements for children's storybook theme: glowing stars, colorful butterflies, floating letters, rainbow trails, 3D cartoon style"
      }

      success_count = 0
      total_count = hero_elements.length

      hero_elements.each do |filename, prompt|
        if generate_image(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 조정
        sleep(2)
      end

      puts "\n🎉 히어로 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts e.backtrace.first(5)
    end
  end
end
