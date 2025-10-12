#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'

puts "🔬 Vertex AI Studio 방식 모방: Publisher Model Operations 해결"

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

# 1. 기존 작업 상태를 다른 방식으로 확인
operation_name = File.read('veo_gesture_operation.txt').strip
puts "📋 기존 작업: #{operation_name}"

# 방법 1: Publisher Model 전용 status 엔드포인트 시도
puts "\n🔍 방법 1: Publisher Model Status API..."
status_url = "https://#{location}-aiplatform.googleapis.com/v1/#{operation_name}:status"
puts "URL: #{status_url}"

begin
  uri = URI(status_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"
  
  response = http.request(request)
  puts "응답: #{response.code} #{response.message}"
  puts "본문: #{response.body[0..300]}" if response.code != '200'
rescue => e
  puts "오류: #{e.message}"
end

# 방법 2: 직접 결과 확인 (완료된 작업은 결과가 다른 곳에 저장될 수 있음)
puts "\n🔍 방법 2: 직접 결과 확인..."
result_url = "https://#{location}-aiplatform.googleapis.com/v1/#{operation_name}:result"
puts "URL: #{result_url}"

begin
  uri = URI(result_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"
  
  response = http.request(request)
  puts "응답: #{response.code} #{response.message}"
  puts "본문: #{response.body[0..300]}" if response.code != '200'
rescue => e
  puts "오류: #{e.message}"
end

# 방법 3: Publisher Model 리스트에서 확인
puts "\n🔍 방법 3: Publisher Model 작업 리스트..."
list_url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001/operations"
puts "URL: #{list_url}"

begin
  uri = URI(list_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"
  
  response = http.request(request)
  puts "응답: #{response.code} #{response.message}"
  
  if response.code == '200'
    result = JSON.parse(response.body)
    puts "✅ 작업 리스트 확인 성공!"
    puts "응답 키: #{result.keys}"
    
    if result['operations']
      puts "작업 개수: #{result['operations'].size}"
      result['operations'].each_with_index do |op, i|
        puts "  작업 #{i+1}: #{op['name']} (완료: #{op['done']})"
      end
    end
  else
    puts "본문: #{response.body[0..300]}"
  end
rescue => e
  puts "오류: #{e.message}"
end

# 방법 4: 새로운 간단한 작업으로 즉시 테스트
puts "\n🔍 방법 4: 새 간단 작업으로 즉시 폴링 테스트..."

# 매우 간단한 작업 시작
uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

simple_body = {
  instances: [{
    prompt: "A simple 2 second test"
  }],
  parameters: {
    video_config: {
      duration_seconds: 2,
      frames_per_second: 12,
      resolution: "720p"
    }
  }
}

request.body = simple_body.to_json
response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  new_op = result['name']
  puts "✅ 새 간단 작업 시작: #{new_op}"
  
  # 즉시 다양한 방식으로 폴링 시도
  sleep 5
  
  [
    "https://#{location}-aiplatform.googleapis.com/v1/#{new_op}",
    "https://#{location}-aiplatform.googleapis.com/v1/#{new_op}:wait",
    "https://#{location}-aiplatform.googleapis.com/v1/#{new_op}/status"
  ].each_with_index do |url, i|
    puts "\n  즉시 폴링 #{i+1}: #{url}"
    begin
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      
      response = http.request(request)
      puts "    응답: #{response.code} #{response.message}"
      
      if response.code == '200'
        result = JSON.parse(response.body)
        puts "    ✅ 성공! 완료: #{result['done']}"
        puts "    📋 응답 구조: #{result.keys}"
      else
        puts "    ❌ #{response.code}: #{response.body[0..200]}"
      end
    rescue => e
      puts "    예외: #{e.message}"
    end
  end
else
  puts "❌ 새 작업 시작 실패: #{response.body}"
end

