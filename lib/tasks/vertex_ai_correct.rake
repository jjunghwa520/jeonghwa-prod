namespace :hero do
  desc "Generate hero characters using correct Vertex AI Imagen API"
  task generate_correct: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🔧 프로젝트 ID: #{project_id}"
    puts "🌍 위치: #{location}"
    
    # 서비스 계정 키 파일 경로
    key_file_path = Rails.root.join('config', 'google_service_account.json')
    
    unless File.exist?(key_file_path)
      puts "❌ 서비스 계정 키 파일을 찾을 수 없습니다: #{key_file_path}"
      exit 1
    end

    # 액세스 토큰 생성 함수
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      puts "🔑 액세스 토큰 획득 완료"
      token['access_token']
    end

    # 올바른 Vertex AI Imagen API 호출
    def generate_image_correct(access_token, project_id, location, prompt, filename)
      # 올바른 Vertex AI Imagen 엔드포인트 (최신 버전)
      model_name = "imagegeneration@006"  # 최신 안정 버전
      endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_name}:predict"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120  # 타임아웃 증가
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      # 올바른 요청 페이로드 구조 (시드 제거)
      payload = {
        instances: [
          {
            prompt: prompt
          }
        ],
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
      puts "📝 프롬프트: #{prompt[0..100]}..."
      puts "🔗 엔드포인트: #{uri}"
      
      response = http.request(request)
      
      puts "📡 응답 코드: #{response.code}"
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0]
          prediction = result['predictions'][0]
          
          if prediction['bytesBase64Encoded']
            image_data = Base64.decode64(prediction['bytesBase64Encoded'])
            
            # 이미지 저장
            output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'hero_correct')
            FileUtils.mkdir_p(output_dir)
            
            file_path = File.join(output_dir, "#{filename}.jpg")
            File.open(file_path, 'wb') do |file|
              file.write(image_data)
            end
            
            puts "✅ 성공: #{filename}.jpg (#{image_data.size} bytes)"
            return true
          elsif prediction['mimeType'] && prediction['bytesBase64Encoded']
            # 다른 형식의 응답 처리
            image_data = Base64.decode64(prediction['bytesBase64Encoded'])
            
            output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'hero_correct')
            FileUtils.mkdir_p(output_dir)
            
            file_path = File.join(output_dir, "#{filename}.jpg")
            File.open(file_path, 'wb') do |file|
              file.write(image_data)
            end
            
            puts "✅ 성공: #{filename}.jpg (#{image_data.size} bytes)"
            return true
          else
            puts "❌ 실패: #{filename} - 이미지 데이터 없음"
            puts "📄 응답 구조: #{prediction.keys.join(', ')}"
            return false
          end
        else
          puts "❌ 실패: #{filename} - predictions 없음"
          puts "📄 전체 응답: #{result}"
          return false
        end
      else
        puts "❌ 실패: #{filename} - HTTP #{response.code}"
        error_body = JSON.parse(response.body) rescue response.body
        puts "📄 오류 내용: #{error_body}"
        return false
      end
    rescue => e
      puts "❌ 예외 발생: #{filename} - #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
      return false
    end

    begin
      access_token = get_access_token(key_file_path)
      
      # 간단한 테스트 프롬프트부터 시작
      test_prompts = {
        "simple_book" => "A colorful children's book, simple illustration, cartoon style",
        "magic_star" => "A golden star with sparkles, magical, fairy tale style",
        "cute_character" => "A friendly cartoon character, simple design, colorful"
      }

      success_count = 0
      total_count = test_prompts.length

      test_prompts.each_with_index do |(filename, prompt), index|
        puts "\n--- 테스트 #{index + 1}/#{total_count} ---"
        
        if generate_image_correct(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격
        sleep(3) if index < total_count - 1
      end

      puts "\n🎉 테스트 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('app', 'assets', 'images', 'generated', 'hero_correct', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first(3).join('\n')}"
    end
  end
end
