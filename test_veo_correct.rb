#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
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

# 올바른 Veo API 엔드포인트 테스트 (predictLongRunning)
puts "\n🎬 Veo 테스트 (올바른 엔드포인트: predictLongRunning)..."

# 1. veo-2.0-generate-001 테스트
uri = URI("https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 60

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

# 올바른 요청 형식
body = {
  instances: [{
    prompt: "A cute cartoon cat walking"
  }],
  parameters: {
    video_config: {
      duration_seconds: 5,
      frames_per_second: 24,
      resolution: "720p"
    }
  }
}

request.body = body.to_json

response = http.request(request)
puts "Veo 2.0 (predictLongRunning) 응답: #{response.code} #{response.message}"
puts "응답 본문: #{response.body[0..1000]}"

if response.code == '200'
  result = JSON.parse(response.body)
  if result['name']
    puts "✅ LRO 작업 시작됨: #{result['name']}"
  end
end

# 2. 다른 리전도 테스트 (asia-southeast1)
puts "\n🌏 다른 리전 테스트 (asia-southeast1)..."
uri = URI("https://asia-southeast1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/asia-southeast1/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 60

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"
request.body = body.to_json

response = http.request(request)
puts "Veo 2.0 (asia-southeast1) 응답: #{response.code} #{response.message}"
puts "응답 본문: #{response.body[0..500]}"

