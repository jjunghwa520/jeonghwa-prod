#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'googleauth'

# 서비스 계정 인증
credentials_path = 'config/google_service_account.json'
project_id = 'gen-lang-client-0492798913'

# 액세스 토큰 가져오기
scope = ['https://www.googleapis.com/auth/cloud-platform']
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(credentials_path),
  scope: scope
)
token_hash = authorizer.fetch_access_token!
token = token_hash['access_token']

puts "✅ 액세스 토큰 획득 완료"

# 1. 새 작업 시작
puts "\n🎬 새 Veo 작업 시작..."
uri = URI("https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 60

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

body = {
  instances: [{
    prompt: "A cute cartoon cat walking for 3 seconds"
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
puts "작업 시작 응답: #{response.code} #{response.message}"

if response.code == '200'
  result = JSON.parse(response.body)
  operation_name = result['name']
  puts "✅ 작업 시작됨: #{operation_name}"
  
  # 2. 올바른 폴링 URL 테스트
  puts "\n🔍 폴링 테스트..."
  
  # operations API 엔드포인트 (표준 형식)
  poll_url = "https://us-central1-aiplatform.googleapis.com/v1/#{operation_name}"
  puts "폴링 URL: #{poll_url}"
  
  uri = URI(poll_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"
  
  response = http.request(request)
  puts "폴링 응답: #{response.code} #{response.message}"
  puts "응답 본문: #{response.body[0..1000]}"
  
  if response.code == '200'
    poll_result = JSON.parse(response.body)
    puts "✅ 폴링 성공!"
    puts "완료 상태: #{poll_result['done']}"
    puts "메타데이터: #{poll_result['metadata']}" if poll_result['metadata']
  end
else
  puts "❌ 작업 시작 실패: #{response.body}"
end

