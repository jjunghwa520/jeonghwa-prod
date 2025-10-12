#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'googleauth'

puts "🔍 Veo 2 작업 상태 간단 확인"

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

operation_name = File.read('veo_operation.txt').strip
operation_id = operation_name.split('/').last

puts "📋 작업 ID: #{operation_id}"

# 다양한 엔드포인트 시도
endpoints = [
  "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/operations/#{operation_id}",
  "https://#{location}-aiplatform.googleapis.com/v1/#{operation_name}",
  "https://aiplatform.googleapis.com/v1/#{operation_name}"
]

endpoints.each_with_index do |endpoint, i|
  puts "\n시도 #{i+1}: #{endpoint}"
  
  begin
    uri = URI(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}"
    
    response = http.request(request)
    puts "응답: #{response.code} #{response.message}"
    
    if response.code == '200'
      result = JSON.parse(response.body)
      puts "✅ 성공! 완료 여부: #{result['done']}"
      
      if result['done']
        puts "🎬 작업 완료됨!"
        break
      else
        puts "⏳ 아직 진행 중..."
      end
      break
    elsif response.code == '404'
      puts "❌ 404 Not Found"
    else
      puts "❌ 기타 오류: #{response.body[0..200]}"
    end
  rescue => e
    puts "❌ 예외: #{e.message}"
  end
end

puts "\n💡 모든 엔드포인트에서 404가 나온다면:"
puts "   1) 작업이 이미 완료되어 삭제되었거나"
puts "   2) 다른 리전에서 실행되었거나"
puts "   3) 작업 ID 형식이 다를 수 있습니다."

