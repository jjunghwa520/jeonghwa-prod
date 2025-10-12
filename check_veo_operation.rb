#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'googleauth'
require 'fileutils'

puts "🔍 Veo 2 동영상 생성 작업 상태 확인"

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
operation_name = File.read('veo_operation.txt').strip
puts "📋 작업명: #{operation_name}"

# 작업 상태 확인
poll_url = "https://#{location}-aiplatform.googleapis.com/v1/#{operation_name}"
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
  puts "  메타데이터: #{result['metadata']}" if result['metadata']
  
  if result['done']
    puts "\n✅ 작업 완료!"
    
    if result['response']
      puts "📋 응답 구조: #{result['response'].keys}"
      
      # 동영상 데이터 확인
      if result['response']['predictions'] && result['response']['predictions'][0]
        prediction = result['response']['predictions'][0]
        puts "예측 결과: #{prediction.keys}"
        
        if prediction['bytesBase64Encoded']
          puts "🎬 동영상 데이터 발견! 다운로드 중..."
          
          video_data = Base64.decode64(prediction['bytesBase64Encoded'])
          output_path = 'public/videos/character_animations/jeonghwa_veo_consistent.webm'
          
          File.binwrite(output_path, video_data)
          puts "✅ 동영상 저장 완료: #{output_path}"
          
          # 파일 크기 확인
          file_size = File.size(output_path)
          puts "📏 파일 크기: #{file_size} bytes (#{file_size / 1024}KB)"
          
        elsif prediction['gcsUri']
          puts "📦 GCS URI: #{prediction['gcsUri']}"
          puts "💡 별도로 GCS에서 다운로드가 필요합니다."
        else
          puts "❓ 예상치 못한 예측 결과 구조: #{prediction}"
        end
      else
        puts "❌ 예측 결과 없음"
        puts "전체 응답: #{result['response']}"
      end
    elsif result['error']
      puts "❌ 작업 오류: #{result['error']}"
    end
  else
    puts "\n⏳ 작업 진행 중..."
    if result['metadata'] && result['metadata']['progressPercentage']
      puts "진행률: #{result['metadata']['progressPercentage']}%"
    end
  end
else
  puts "❌ 폴링 실패: #{response.body}"
end

