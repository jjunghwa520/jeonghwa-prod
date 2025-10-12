require 'net/http'
require 'json'
require 'googleauth'

class SimpleVertexTest
  def self.test_with_http
    puts "=== HTTP를 통한 Vertex AI 테스트 ==="
    
    begin
      # 프로젝트 정보
      project_id = 'gen-lang-client-0492798913'
      location = 'us-central1'
      
      # 인증 설정
      credentials_path = Rails.root.join('config', 'google_service_account.json')
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
      
      # Google Auth 라이브러리를 사용하여 액세스 토큰 가져오기
      scope = 'https://www.googleapis.com/auth/cloud-platform'
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_path),
        scope: scope
      )
      
      # 액세스 토큰 가져오기
      authorizer.fetch_access_token!
      access_token = authorizer.access_token
      
      puts "✅ 액세스 토큰 획득 성공"
      puts "토큰 (처음 20자): #{access_token[0..19]}..."
      
      # Gemini Pro 모델 테스트 (버전 명시)
      url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/gemini-1.0-pro-001:predict"
      
      # 요청 본문
      request_body = {
        instances: [
          {
            content: "Say hello in Korean"
          }
        ],
        parameters: {
          temperature: 0.2,
          maxOutputTokens: 100
        }
      }
      
      # HTTP 요청 생성
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = request_body.to_json
      
      puts "\n요청 URL: #{url}"
      puts "요청 본문: #{request_body.to_json}"
      
      # API 호출
      puts "\nAPI 호출 중..."
      response = http.request(request)
      
      puts "응답 코드: #{response.code}"
      
      if response.code == '200'
        puts "✅ API 호출 성공!"
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'].any?
          content = result['predictions'].first['content']
          puts "\n생성된 텍스트: #{content}"
        end
      else
        puts "❌ API 호출 실패"
        puts "응답 본문: #{response.body}"
      end
      
      return response.code == '200'
      
    rescue => e
      puts "❌ 오류 발생: #{e.message}"
      puts e.backtrace.first(3).join("\n")
      return false
    end
  end
  
  def self.test_image_generation
    puts "\n=== Imagen을 통한 이미지 생성 테스트 ==="
    
    begin
      project_id = 'gen-lang-client-0492798913'
      location = 'us-central1'
      
      # 인증
      credentials_path = Rails.root.join('config', 'google_service_account.json')
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
      
      scope = 'https://www.googleapis.com/auth/cloud-platform'
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_path),
        scope: scope
      )
      
      authorizer.fetch_access_token!
      access_token = authorizer.access_token
      
      # Imagen 모델 사용
      url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/imagegeneration@002:predict"
      
      request_body = {
        instances: [
          {
            prompt: "A modern online education platform banner with blue and white colors, professional and clean design"
          }
        ],
        parameters: {
          sampleCount: 1,
          aspectRatio: "16:9",
          negativePrompt: "low quality, blurry"
        }
      }
      
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 60  # 이미지 생성은 시간이 걸림
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = request_body.to_json
      
      puts "요청 URL: #{url}"
      puts "프롬프트: #{request_body[:instances].first[:prompt]}"
      puts "\nAPI 호출 중... (최대 30초 소요)"
      
      response = http.request(request)
      
      puts "응답 코드: #{response.code}"
      
      if response.code == '200'
        puts "✅ 이미지 생성 성공!"
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'].any?
          prediction = result['predictions'].first
          if prediction['bytesBase64Encoded']
            puts "이미지 데이터 수신 완료 (Base64 인코딩)"
            
            # 이미지 저장
            image_data = Base64.decode64(prediction['bytesBase64Encoded'])
            filename = "test_image_#{Time.now.to_i}.png"
            filepath = Rails.root.join('public', 'generated_images', filename)
            
            FileUtils.mkdir_p(File.dirname(filepath))
            File.open(filepath, 'wb') { |f| f.write(image_data) }
            
            puts "이미지 저장 완료: /generated_images/#{filename}"
          end
        end
      else
        puts "❌ 이미지 생성 실패"
        error_body = JSON.parse(response.body) rescue response.body
        
        if error_body.is_a?(Hash) && error_body['error']
          puts "오류 코드: #{error_body['error']['code']}"
          puts "오류 메시지: #{error_body['error']['message']}"
          
          # 상세 오류 정보
          if error_body['error']['details']
            puts "상세 정보:"
            error_body['error']['details'].each do |detail|
              puts "  - #{detail}"
            end
          end
        else
          puts "응답: #{response.body[0..500]}"
        end
      end
      
      return response.code == '200'
      
    rescue => e
      puts "❌ 오류 발생: #{e.message}"
      puts e.backtrace.first(3).join("\n")
      return false
    end
  end
end
