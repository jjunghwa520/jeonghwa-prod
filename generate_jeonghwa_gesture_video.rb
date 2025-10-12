#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'
require 'fileutils'

puts "🎬 정화 캐릭터 제스처 동영상 생성 (Veo 2 + 이미지→동영상)"
puts "📝 동작: 오른쪽으로 걸어가기 → 정면 바라보기 → 손 내밀어 확인 제스처"

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

# Veo 2 이미지→동영상 생성 (정확한 엔드포인트)
puts "\n🎬 Veo 2로 제스처 동영상 생성 중..."

uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-2.0-generate-001:predictLongRunning")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 120

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"

# 정확한 동작 시퀀스 프롬프트
gesture_prompt = "The character walks naturally to the right for 2 seconds, then smoothly turns to face the camera, then extends her right hand forward in a welcoming 'come and see' gesture with a warm smile. The movement should be smooth, natural, and professional. Maintain the exact same character appearance, clothing, and style. Keep the transparent background throughout the entire animation. The walking should show natural leg movement and arm swing, the turn should be a smooth 90-degree rotation, and the final gesture should be inviting and friendly."

body = {
  instances: [{
    prompt: gesture_prompt,
    image: {
      bytesBase64Encoded: image_data,
      mimeType: "image/png"
    }
  }],
  parameters: {
    video_config: {
      duration_seconds: 6,
      frames_per_second: 24,
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
  puts "✅ 제스처 동영상 작업 시작됨!"
  puts "📋 작업명: #{operation_name}"
  
  # 작업명을 파일에 저장
  File.write('veo_gesture_operation.txt', operation_name)
  
  puts "\n⏳ 동영상 생성 중... (약 3-7분 소요)"
  puts "🎯 동작 시퀀스: 걷기(2초) → 돌기(1초) → 제스처(3초)"
  puts "📁 완료 후 저장될 위치: public/videos/character_animations/jeonghwa_gesture.webm"
  
  puts "\n💡 5분 후에 완료 상태를 확인하겠습니다..."
  
else
  puts "❌ 작업 시작 실패: #{response.body}"
end

