namespace :image_to_video do
  desc "Generate character videos from standard images using image-to-video"
  task generate: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'fileutils'

    puts "🎬 이미지 투 비디오: 표준 캐릭터 동영상 생성 시작!"
    
    # Gemini API 키
    api_key = ENV['GEMINI_API_KEY']
    
    if api_key.blank?
      puts "❌ GEMINI_API_KEY가 설정되지 않았습니다!"
      return
    end

    # 동영상 저장 디렉토리
    video_dir = Rails.root.join('public', 'videos', 'character_animations')
    FileUtils.mkdir_p(video_dir)

    # 표준 캐릭터 이미지들
    standard_images = {
      'jeonghwa' => '/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png',
      'bear' => '/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png',
      'rabbit' => '/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/rabbit_separated.png'
    }

    # 캐릭터별 동영상 프롬프트 (이미지 기반)
    character_animations = {
      # 정화 선생님 동영상들
      'jeonghwa_walking' => {
        base_image: 'jeonghwa',
        prompt: 'Korean female educator character walking naturally from left to right, then turning to face camera with welcoming gesture, smooth professional movement, transparent background, no floor visible, 3D animation style',
        filename: 'jeonghwa_walking.mp4'
      },
      
      'jeonghwa_teaching' => {
        base_image: 'jeonghwa',
        prompt: 'Korean female educator character making teaching gestures, pointing and explaining, nodding approvingly, professional educator movements, transparent background, no floor visible, 3D animation style',
        filename: 'jeonghwa_teaching.mp4'
      },
      
      'jeonghwa_presenting' => {
        base_image: 'jeonghwa',
        prompt: 'Korean female educator character presenting proudly, gesturing with confidence, showing achievements, satisfied expression, transparent background, no floor visible, 3D animation style',
        filename: 'jeonghwa_presenting.mp4'
      },

      # 곰 학생 동영상들
      'bear_curious' => {
        base_image: 'bear',
        prompt: 'Cute brown bear character waddling curiously, tilting head with interest, leaning forward to observe, nodding with understanding, adorable expressions, transparent background, floating in air, 3D animation style',
        filename: 'bear_curious.mp4'
      },
      
      'bear_studying' => {
        base_image: 'bear',
        prompt: 'Cute brown bear character focusing on learning, nodding while studying, occasionally looking up with interest, thoughtful expressions, transparent background, floating in air, 3D animation style',
        filename: 'bear_studying.mp4'
      },
      
      'bear_celebrating' => {
        base_image: 'bear',
        prompt: 'Cute brown bear character doing happy celebration, gentle victory dance, nodding with joy, expressing success, cheerful movements, transparent background, floating in air, 3D animation style',
        filename: 'bear_celebrating.mp4'
      },

      # 토끼 학생 동영상들
      'rabbit_hopping' => {
        base_image: 'rabbit',
        prompt: 'Cute white rabbit character hopping energetically, ears bouncing naturally, landing gracefully, then turning to point excitedly, enthusiastic expressions, transparent background, floating in air, 3D animation style',
        filename: 'rabbit_hopping.mp4'
      },
      
      'rabbit_eager' => {
        base_image: 'rabbit',
        prompt: 'Cute white rabbit character bouncing with excitement, raising paw enthusiastically, ears perked up with interest, eager learning behavior, transparent background, floating in air, 3D animation style',
        filename: 'rabbit_eager.mp4'
      },
      
      'rabbit_victory' => {
        base_image: 'rabbit',
        prompt: 'Cute white rabbit character jumping with joy, doing victory hops, ears flying with excitement, celebrating success, pure happiness, transparent background, floating in air, 3D animation style',
        filename: 'rabbit_victory.mp4'
      }
    }

    # 각 캐릭터 동영상 생성
    character_animations.each_with_index do |(video_key, video_data), index|
      puts "\n🎬 [#{index + 1}/#{character_animations.size}] #{video_key} 이미지→동영상 생성 중..."
      
      video_path = video_dir.join(video_data[:filename])
      
      if File.exist?(video_path)
        puts "    ⏭️  이미 존재함: #{video_data[:filename]}"
        next
      end

      # 기본 이미지 읽기
      base_image_path = standard_images[video_data[:base_image]]
      unless File.exist?(base_image_path)
        puts "    ❌ 기본 이미지 없음: #{base_image_path}"
        next
      end

      begin
        # 이미지를 Base64로 인코딩
        image_data = Base64.strict_encode64(File.read(base_image_path))
        
        # Gemini API 이미지→동영상 생성
        uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent')
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 120
        
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['x-goog-api-key'] = api_key
        
        # 이미지→동영상 요청 구조
        request.body = {
          contents: [{
            parts: [
              {
                text: "Create an animated video from this character image: #{video_data[:prompt]}"
              },
              {
                inlineData: {
                  mimeType: "image/png",
                  data: image_data
                }
              }
            ]
          }]
        }.to_json
        
        puts "    📡 이미지→동영상 API 요청 중..."
        response = http.request(request)
        
        if response.code == '200'
          result = JSON.parse(response.body)
          puts "    📋 응답 확인: #{result.keys}"
          
          # 동영상 데이터 확인
          if result['candidates'] && result['candidates'][0] && 
             result['candidates'][0]['content'] && 
             result['candidates'][0]['content']['parts']
            
            parts = result['candidates'][0]['content']['parts']
            video_part = parts.find { |part| part['inlineData'] && part['inlineData']['mimeType']&.include?('video') }
            
            if video_part && video_part['inlineData']
              video_base64 = video_part['inlineData']['data']
              File.open(video_path, 'wb') do |file|
                file.write(Base64.decode64(video_base64))
              end
              puts "    ✅ 동영상 생성 완료!"
            else
              puts "    ⏳ 동영상 생성 처리 중..."
              puts "    📋 응답 구조: #{result}"
            end
          else
            puts "    ❌ 예상과 다른 응답: #{result}"
          end
        else
          puts "    ❌ API 오류: #{response.code} - #{response.body}"
        end
        
      rescue => e
        puts "    ❌ 오류: #{e.message}"
        next
      end

      # API 제한 대응
      sleep(5)
    end

    puts "\n🎉 이미지→동영상 생성 작업 완료!"
    puts "📁 저장 위치: public/videos/character_animations/"
  end
end

