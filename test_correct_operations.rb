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
    prompt: "A simple test animation"
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
  
  # 2. 다양한 폴링 URL 패턴 시도
  puts "\n🔍 다양한 폴링 URL 테스트..."
  
  poll_urls = [
    # 패턴 1: 표준 operations API
    "https://us-central1-aiplatform.googleapis.com/v1/#{operation_name}",
    
    # 패턴 2: 프로젝트 기반 operations
    "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/operations/#{operation_name.split('/').last}",
    
    # 패턴 3: 단순 operations
    "https://us-central1-aiplatform.googleapis.com/v1/operations/#{operation_name.split('/').last}",
    
    # 패턴 4: LongRunning Operations API
    "https://us-central1-longrunning.googleapis.com/v1/#{operation_name}"
  ]
  
  poll_urls.each_with_index do |poll_url, i|
    puts "\n패턴 #{i+1}: #{poll_url}"
    
    begin
      uri = URI(poll_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      
      response = http.request(request)
      puts "  응답: #{response.code} #{response.message}"
      
      if response.code == '200'
        poll_result = JSON.parse(response.body)
        puts "  ✅ 폴링 성공! 완료: #{poll_result['done']}"
        if poll_result['metadata']
          puts "  메타데이터: #{poll_result['metadata'].keys}"
        end
        break  # 성공하면 중단
      elsif response.code == '404'
        puts "  ❌ 404 Not Found"
      else
        puts "  ❌ 기타 오류: #{response.body[0..200]}"
      end
    rescue => e
      puts "  ❌ 예외: #{e.message}"
    end
  end
else
  puts "❌ 작업 시작 실패: #{response.body}"
end

