namespace :hero do
  desc "Generate final hero characters using correct Vertex AI method"
  task generate_final: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🎨 히어로 캐릭터 최종 생성 시작!"
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

    # 올바른 Vertex AI 이미지 생성
    def generate_hero_image(access_token, project_id, location, prompt, filename)
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
      
      puts "🎨 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..80]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'hero_final')
          FileUtils.mkdir_p(output_dir)
          
          file_path = File.join(output_dir, "#{filename}.jpg")
          File.open(file_path, 'wb') { |file| file.write(image_data) }
          
          puts "✅ 성공: #{filename}.jpg (#{(image_data.size / 1024.0 / 1024.0).round(2)}MB)"
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
      
      # 히어로 섹션용 캐릭터 및 요소들 (안전한 프롬프트)
      hero_elements = {
        "main_reading_child" => "A cheerful child sitting cross-legged reading a colorful storybook, 3D cartoon style, Pixar quality, bright colors, friendly smile, casual clothes",
        
        "floating_storybook_1" => "A magical floating children's book with golden pages and sparkles, 3D rendered, fairy tale style, soft pastel colors, dreamy atmosphere",
        
        "floating_storybook_2" => "An open colorful children's book floating in air, 3D cartoon style, rainbow colors, magical sparkles around it",
        
        "floating_storybook_3" => "A stack of colorful children's books floating with magical particles, 3D rendered, warm lighting, storybook aesthetic",
        
        "child_waving_hello" => "A happy child character waving hello with big smile, 3D cartoon style, colorful t-shirt, friendly expression, Pixar animation quality",
        
        "child_with_book" => "A smiling child holding a colorful storybook, 3D cartoon style, proud expression, bright school clothes, animation quality",
        
        "magical_fairy_elements" => "Floating fairy tale elements: golden stars, colorful hearts, musical notes, magic sparkles, 3D cartoon style, pastel colors",
        
        "storybook_magic_items" => "Magical storybook items: glowing stars, colorful butterflies, floating letters, rainbow trails, 3D cartoon style, child-friendly"
      }

      success_count = 0
      total_count = hero_elements.length

      hero_elements.each_with_index do |(filename, prompt), index|
        puts "\n--- 생성 #{index + 1}/#{total_count} ---"
        
        if generate_hero_image(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 (할당량 고려)
        sleep(4) if index < total_count - 1
      end

      puts "\n🎉 히어로 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('app', 'assets', 'images', 'generated', 'hero_final', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🔗 사용법:"
        puts "  <%= image_tag 'generated/hero_final/파일명.jpg' %>"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

