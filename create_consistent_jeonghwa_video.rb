#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'
require 'fileutils'

puts "🎬 일관성 있는 정화 캐릭터 동영상 생성 (Veo 2 + 이미지 투 비디오)"

# 서비스 계정 인증
credentials_path = 'config/google_service_account.json'
project_id = 'gen-lang-client-0492798913'
location = 'us-central1'

# 액세스 토큰 가져오기
scope = ['https://www.googleapis.com/auth/cloud-platform']
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(credentials_path),
  scope: scope
)
token_hash = authorizer.fetch_access_token!
token = token_hash['access_token']

puts "✅ 액세스 토큰 획득 완료"

# 원본 정화 이미지 읽기
base_image_path = 'public/images/refined/jeonghwa_refined_isnet-general-use.png'
unless File.exist?(base_image_path)
  puts "❌ 원본 정화 이미지 없음: #{base_image_path}"
  exit 1
end

image_data = Base64.strict_encode64(File.read(base_image_path))
puts "📸 원본 정화 이미지 로드 완료"

# 출력 디렉토리
output_dir = 'public/videos/character_animations'
FileUtils.mkdir_p(output_dir)

# Veo 2 이미지→동영상 생성
puts "\n🎬 Veo 2로 이미지→동영상 생성 중..."

uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 120

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

# 이미지→동영상 요청 (부드럽고 자연스러운 움직임)
body = {
  instances: [{
    prompt: "The character gently breathing and making subtle natural movements, very soft and calm animation, maintaining the exact same appearance and style, transparent background preserved",
    image: {
      bytesBase64Encoded: image_data,
      mimeType: "image/png"
    }
  }],
  parameters: {
    video_config: {
      duration_seconds: 4,
      frames_per_second: 12,
      resolution: "720p"
    }
  }
}

request.body = body.to_json

response = http.request(request)
puts "Veo 2 응답: #{response.code} #{response.message}"

if response.code == '200'
  result = JSON.parse(response.body)
  operation_name = result['name']
  puts "✅ 작업 시작됨: #{operation_name}"
  
  # 폴링은 생략하고 작업명만 기록
  puts "⏳ 동영상 생성 중... (약 2-5분 소요)"
  puts "📋 작업명을 기록했습니다. 나중에 수동으로 확인하세요."
  
  # 작업명을 파일에 저장
  File.write('veo_operation.txt', operation_name)
  
else
  puts "❌ 작업 시작 실패: #{response.body}"
end

puts "\n💡 팁: 작업이 완료되면 Google Cloud Console에서 결과를 확인하거나"
puts "    별도 스크립트로 operation을 폴링해서 결과를 다운로드하세요."
