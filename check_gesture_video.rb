#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'
require 'fileutils'

puts "🔍 정화 제스처 동영상 생성 상태 확인"

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

# 저장된 작업명 읽기
operation_name = File.read('veo_gesture_operation.txt').strip
operation_id = operation_name.split('/').last

puts "📋 제스처 작업 ID: #{operation_id}"

# 표준 operations API로 상태 확인
poll_url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/operations/#{operation_id}"
puts "🔗 폴링 URL: #{poll_url}"

uri = URI(poll_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"

response = http.request(request)
puts "응답 상태: #{response.code} #{response.message}"

if response.code == '200'
  result = JSON.parse(response.body)
  
  puts "\n📊 작업 상태:"
  puts "  완료 여부: #{result['done']}"
  
  if result['done']
    puts "\n✅ 제스처 동영상 작업 완료!"
    
    if result['response'] && result['response']['predictions'] && result['response']['predictions'][0]
      prediction = result['response']['predictions'][0]
      
      if prediction['bytesBase64Encoded']
        puts "🎬 동영상 데이터 발견! 다운로드 중..."
        
        video_data = Base64.decode64(prediction['bytesBase64Encoded'])
        output_path = 'public/videos/character_animations/jeonghwa_gesture.webm'
        
        File.binwrite(output_path, video_data)
        puts "✅ 제스처 동영상 저장 완료: #{output_path}"
        
        # 파일 크기 확인
        file_size = File.size(output_path)
        puts "📏 파일 크기: #{(file_size / 1024.0 / 1024.0).round(2)}MB"
        
        puts "\n🎯 이제 히어로 섹션에 적용할 준비가 완료되었습니다!"
        
      elsif prediction['gcsUri']
        puts "📦 GCS URI: #{prediction['gcsUri']}"
        puts "💡 GCS에서 직접 다운로드가 필요합니다."
      else
        puts "❓ 예상치 못한 결과 구조"
        puts "전체 예측 결과: #{prediction.keys}"
      end
    elsif result['error']
      puts "❌ 작업 오류: #{result['error']}"
    else
      puts "❌ 예상치 못한 응답 구조"
      puts "전체 응답: #{result.keys}"
    end
  else
    puts "\n⏳ 아직 진행 중..."
    if result['metadata']
      puts "📊 메타데이터: #{result['metadata']}"
    end
    puts "💡 잠시 후 다시 확인해주세요."
  end
else
  puts "❌ 상태 확인 실패: #{response.code}"
  puts "응답: #{response.body[0..500]}"
end

