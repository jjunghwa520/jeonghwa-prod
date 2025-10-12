require 'net/http'
require 'json'
require 'base64'

class TestVertexAi
  def self.test_connection
    puts "=== Vertex AI 연결 테스트 ==="
    
    # 환경 변수 확인
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'gen-lang-client-0492798913'
    location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'
    
    puts "프로젝트 ID: #{project_id}"
    puts "위치: #{location}"
    
    # 서비스 계정 파일 확인
    credentials_path = Rails.root.join('config', 'google_service_account.json')
    if File.exist?(credentials_path)
      puts "✅ 서비스 계정 파일 존재: #{credentials_path}"
      
      # JSON 파일 읽기
      credentials = JSON.parse(File.read(credentials_path))
      puts "서비스 계정 이메일: #{credentials['client_email']}"
    else
      puts "❌ 서비스 계정 파일 없음"
      return false
    end
    
    # Google Cloud 클라이언트 라이브러리 테스트
    begin
      require 'google/cloud/ai_platform/v1'
      puts "✅ Google Cloud AI Platform 라이브러리 로드 성공"
      
      # 환경 변수 설정
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
      
      # 클라이언트 초기화 테스트
      client = ::Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
        config.endpoint = "#{location}-aiplatform.googleapis.com"
      end
      
      puts "✅ Vertex AI 클라이언트 초기화 성공"
      
      # 엔드포인트 확인
      endpoint = "projects/#{project_id}/locations/#{location}"
      puts "엔드포인트: #{endpoint}"
      
      return true
    rescue => e
      puts "❌ 오류 발생: #{e.message}"
      puts e.backtrace.first(3).join("\n")
      return false
    end
  end
  
  def self.test_simple_prediction
    puts "\n=== 간단한 예측 테스트 ==="
    
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'gen-lang-client-0492798913'
    location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'
    
    # Gemini Pro 모델로 테스트 (텍스트 생성)
    endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/gemini-pro:predict"
    
    request_body = {
      instances: [
        {
          content: "Hello, this is a test"
        }
      ],
      parameters: {
        temperature: 0.2,
        maxOutputTokens: 256,
        topK: 40,
        topP: 0.95
      }
    }
    
    puts "엔드포인트: #{endpoint}"
    puts "요청 본문: #{request_body.to_json[0..200]}..."
    
    begin
      credentials_path = Rails.root.join('config', 'google_service_account.json')
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
      
      client = ::Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
        config.endpoint = "#{location}-aiplatform.googleapis.com"
      end
      
      # API 호출
      response = client.predict(
        endpoint: endpoint,
        instances: request_body[:instances].map { |i| Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: i.transform_keys(&:to_s).transform_values { |v| Google::Protobuf::Value.new(string_value: v.to_s) })) },
        parameters: Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: request_body[:parameters].transform_keys(&:to_s).transform_values { |v| Google::Protobuf::Value.new(number_value: v.is_a?(Numeric) ? v : v.to_f) }))
      )
      
      puts "✅ API 호출 성공!"
      puts "응답: #{response.predictions.first.to_json[0..200]}..." if response.predictions.any?
      
      return true
    rescue => e
      puts "❌ API 호출 실패: #{e.message}"
      puts "오류 클래스: #{e.class}"
      
      # Google Cloud 오류인 경우 더 자세한 정보 출력
      if e.respond_to?(:status_code)
        puts "상태 코드: #{e.status_code}"
        puts "상세 메시지: #{e.details}"
      end
      
      return false
    end
  end
end
