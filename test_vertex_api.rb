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

puts "✅ 액세스 토큰 획득 완료 (#{token[0..20]}...)"

# 1. Imagen 테스트 (asia-northeast3)
puts "\n📸 Imagen 테스트 (asia-northeast3)..."
uri = URI("https://asia-northeast3-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/asia-northeast3/publishers/google/models/imagegeneration@006:predict")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 30

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

body = {
  instances: [{
    prompt: "A cute cartoon cat"
  }],
  parameters: {
    sampleCount: 1
  }
}

request.body = body.to_json

response = http.request(request)
puts "Imagen 응답: #{response.code} #{response.message}"
if response.code != '200'
  puts "오류 내용: #{response.body[0..500]}"
end

# 2. Veo 테스트 (us-central1)
puts "\n🎬 Veo 테스트 (us-central1)..."
uri = URI("https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/veo-2.0-generate-001:predict")

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

body = {
  instances: [{
    prompt: "A cat walking",
    video_config: {
      duration_seconds: 5,
      frames_per_second: 24,
      resolution: "720p"
    }
  }],
  parameters: {
    sampleCount: 1
  }
}

request.body = body.to_json

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 30

response = http.request(request)
puts "Veo 응답: #{response.code} #{response.message}"
if response.code != '200'
  puts "오류 내용: #{response.body[0..500]}"
end

