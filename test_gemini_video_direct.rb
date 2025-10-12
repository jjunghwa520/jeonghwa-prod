#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'base64'
require 'fileutils'

puts "🎬 Gemini API 직접 사용으로 Veo 동영상 생성 테스트"

# Gemini API 키 확인
api_key = ENV['GEMINI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "❌ GEMINI_API_KEY가 설정되지 않았습니다!"
  exit 1
end

puts "✅ Gemini API 키 확인 완료"

# 원본 정화 이미지 읽기
base_image_path = 'public/images/refined/jeonghwa_refined_isnet-general-use.png'
unless File.exist?(base_image_path)
  puts "❌ 원본 정화 이미지 없음: #{base_image_path}"
  exit 1
end

image_data = Base64.strict_encode64(File.read(base_image_path))
puts "📸 원본 정화 이미지 로드 완료"

# 1. Gemini 2.5 Flash Image로 이미지 편집 시도
puts "\n🖼️ Gemini 2.5 Flash Image로 동작 프레임 생성 시도..."

uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 120

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['x-goog-api-key'] = api_key

# 동작별 프레임 생성 요청
frames_to_generate = [
  {
    name: "walking_right",
    prompt: "Edit this character image to show her walking to the right with natural leg movement and arm swing, maintain exact same appearance and clothing style, transparent background"
  },
  {
    name: "turning_front", 
    prompt: "Edit this character image to show her turning to face the camera, mid-turn pose, maintain exact same appearance and clothing style, transparent background"
  },
  {
    name: "gesture_welcome",
    prompt: "Edit this character image to show her extending her right hand forward in a welcoming gesture with warm smile, maintain exact same appearance and clothing style, transparent background"
  }
]

generated_frames = []

frames_to_generate.each_with_index do |frame_data, i|
  puts "\n📸 [#{i+1}/#{frames_to_generate.size}] #{frame_data[:name]} 프레임 생성 중..."
  
  request_body = {
    contents: [{
      parts: [
        {
          text: frame_data[:prompt]
        },
        {
          inlineData: {
            mimeType: "image/png",
            data: image_data
          }
        }
      ]
    }],
    generationConfig: {
      aspectRatio: "1:1"
    }
  }
  
  request.body = request_body.to_json
  
  response = http.request(request)
  puts "  응답: #{response.code} #{response.message}"
  
  if response.code == '200'
    result = JSON.parse(response.body)
    
    if result['candidates'] && result['candidates'][0] && 
       result['candidates'][0]['content'] && 
       result['candidates'][0]['content']['parts']
      
      parts = result['candidates'][0]['content']['parts']
      image_part = parts.find { |part| part['inlineData'] && part['inlineData']['mimeType']&.include?('image') }
      
      if image_part && image_part['inlineData']
        frame_data_b64 = image_part['inlineData']['data']
        
        # 프레임 저장
        frame_path = "app/assets/images/generated/jeonghwa_#{frame_data[:name]}.png"
        File.binwrite(frame_path, Base64.decode64(frame_data_b64))
        
        generated_frames << frame_path
        puts "  ✅ 프레임 생성 완료: #{frame_path}"
      else
        puts "  ❌ 이미지 데이터 없음"
      end
    else
      puts "  ❌ 예상과 다른 응답: #{result}"
    end
  else
    puts "  ❌ API 오류: #{response.body[0..300]}"
  end
  
  sleep 3  # API 제한 방지
end

# 2. 생성된 프레임들로 비디오 합성
if generated_frames.size >= 3
  puts "\n🎞️ 생성된 프레임들로 비디오 합성..."
  
  # 프레임들을 순차적으로 리네임
  temp_dir = '/tmp/jeonghwa_frames'
  FileUtils.mkdir_p(temp_dir)
  
  generated_frames.each_with_index do |frame_path, i|
    temp_frame = "#{temp_dir}/frame_#{sprintf('%02d', i+1)}.png"
    FileUtils.cp(frame_path, temp_frame)
  end
  
  output_path = 'public/videos/character_animations/jeonghwa_gesture_final.webm'
  
  # FFmpeg로 비디오 합성 (각 프레임 2초씩)
  cmd = "ffmpeg -y -framerate 0.5 -i '#{temp_dir}/frame_%02d.png' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 1M '#{output_path}'"
  
  puts "실행: #{cmd}"
  system(cmd)
  
  if File.exist?(output_path)
    puts "✅ 제스처 동영상 완성: #{output_path}"
    puts "📏 파일 크기: #{(File.size(output_path) / 1024.0).round(1)}KB"
  else
    puts "❌ 비디오 합성 실패"
  end
  
  # 임시 파일 정리
  FileUtils.rm_rf(temp_dir)
  
else
  puts "\n❌ 충분한 프레임이 생성되지 않음 (#{generated_frames.size}/3)"
end
