#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'googleauth'

puts "🔍 Operations API 엔드포인트 체계적 분석"

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

# 새 작업 시작하여 올바른 operation name 형식 확인
puts "\n🎬 새 테스트 작업 시작..."
uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 60

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

body = {
  instances: [{
    prompt: "Simple test animation"
  }],
  parameters: {
    video_config: {
      duration_seconds: 3,
      frames_per_second: 24,
      resolution: "720p"
    }
  }
}

request.body = body.to_json
response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  operation_name = result['name']
  puts "✅ 새 작업 시작: #{operation_name}"
  
  # operation name 분석
  parts = operation_name.split('/')
  puts "\n📋 Operation Name 분석:"
  puts "  전체: #{operation_name}"
  puts "  Parts: #{parts}"
  puts "  마지막 부분 (ID): #{parts.last}"
  
  # 다양한 Operations API 엔드포인트 시도
  puts "\n🔍 다양한 Operations API 엔드포인트 테스트:"
  
  # 1. Standard AI Platform Operations API
  test_endpoints = [
    # 패턴 1: 표준 aiplatform operations
    "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/operations/#{parts.last}",
    
    # 패턴 2: Long Running Operations API (별도 서비스)
    "https://#{location}-longrunning.googleapis.com/v1/#{operation_name}",
    
    # 패턴 3: AI Platform의 전체 경로 유지
    "https://#{location}-aiplatform.googleapis.com/v1/#{operation_name}",
    
    # 패턴 4: Global Operations API
    "https://aiplatform.googleapis.com/v1/#{operation_name}",
    
    # 패턴 5: Compute Engine Operations (혹시나)
    "https://compute.googleapis.com/compute/v1/projects/#{project_id}/global/operations/#{parts.last}",
    
    # 패턴 6: Resource Manager Operations
    "https://cloudresourcemanager.googleapis.com/v1/operations/#{parts.last}"
  ]
  
  test_endpoints.each_with_index do |endpoint, i|
    puts "\n패턴 #{i+1}: #{endpoint}"
    
    begin
      uri = URI(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      
      response = http.request(request)
      puts "  응답: #{response.code} #{response.message}"
      
      if response.code == '200'
        result = JSON.parse(response.body)
        puts "  ✅ 성공! 키: #{result.keys}"
        puts "  완료 여부: #{result['done']}"
        puts "  🎯 올바른 엔드포인트 발견!"
        
        # 올바른 엔드포인트를 파일에 저장
        File.write('correct_operations_endpoint.txt', endpoint.gsub(parts.last, 'OPERATION_ID'))
        puts "  📝 엔드포인트 패턴 저장됨"
        break
        
      elsif response.code == '400'
        error_body = JSON.parse(response.body) rescue response.body
        puts "  ❌ 400: #{error_body}"
        
      elsif response.code == '404'
        puts "  ❌ 404: Not Found"
        
      else
        puts "  ❌ #{response.code}: #{response.body[0..100]}"
      end
      
    rescue => e
      puts "  ❌ 예외: #{e.message}"
    end
    
    sleep 1  # API 제한 방지
  end
  
else
  puts "❌ 새 작업 시작 실패: #{response.code} #{response.body}"
end

