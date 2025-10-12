#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'
require 'fileutils'

puts "🎯 대안 접근: Vertex AI Batch Jobs 또는 다른 Veo 엔드포인트"

credentials_path = 'config/google_service_account.json'
project_id = 'gen-lang-client-0492798913'
location = 'us-central1'

scope = ['https://www.googleapis.com/auth/cloud-platform']
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(credentials_path),
  scope: scope
)
token_hash = authorizer.fetch_access_token!
token = token_hash['access_token']

puts "✅ 인증 완료"

# 원본 정화 이미지
base_image_path = 'public/images/refined/jeonghwa_refined_isnet-general-use.png'
image_data = Base64.strict_encode64(File.read(base_image_path))

# 방법 1: Vertex AI Batch Job API 시도
puts "\n🔍 방법 1: Batch Job API..."
batch_url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/batchPredictionJobs"

batch_body = {
  displayName: "jeonghwa-gesture-video",
  model: "projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001",
  inputConfig: {
    instancesFormat: "jsonl",
    gcsSource: {
      uris: ["gs://temp-bucket/input.jsonl"]  # 임시
    }
  },
  outputConfig: {
    gcsDestination: {
      outputUriPrefix: "gs://temp-bucket/output/"  # 임시
    }
  }
}

begin
  uri = URI(batch_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{token}"
  request.body = batch_body.to_json
  
  response = http.request(request)
  puts "Batch Job 응답: #{response.code} #{response.message}"
  puts "본문: #{response.body[0..500]}" if response.code != '200'
rescue => e
  puts "Batch Job 오류: #{e.message}"
end

# 방법 2: 다른 Veo 모델 시도 (imagen-video 등)
puts "\n🔍 방법 2: 다른 비디오 모델 시도..."

alternative_models = [
  "imagen-video-001",
  "imagen-video-preview-001", 
  "video-generation-001"
]

alternative_models.each do |model|
  puts "\n  모델 #{model} 테스트..."
  
  uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/#{model}:predict")
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{token}"
  
  test_body = {
    instances: [{
      prompt: "A simple test animation"
    }]
  }
  
  request.body = test_body.to_json
  
  begin
    response = http.request(request)
    puts "    응답: #{response.code} #{response.message}"
    
    if response.code == '200'
      result = JSON.parse(response.body)
      puts "    ✅ 성공! 이 모델 사용 가능: #{model}"
      puts "    응답 구조: #{result.keys}"
      break
    elsif response.code == '404'
      puts "    ❌ 모델 없음"
    else
      puts "    ❌ 기타: #{response.body[0..200]}"
    end
  rescue => e
    puts "    예외: #{e.message}"
  end
end

puts "\n💡 결론: Publisher Model Operations는 특별한 폴링 방식이 필요하거나"
puts "    완료 후 자동으로 결과가 다른 위치에 저장될 수 있습니다."

