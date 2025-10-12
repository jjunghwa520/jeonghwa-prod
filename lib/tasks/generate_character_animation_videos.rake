namespace :character_videos do
  desc "Generate character animation videos using Veo 3 for seamless loops"
  task generate: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'fileutils'

    puts "🎬 캐릭터 애니메이션 동영상 생성 시작!"
    puts "🎵 Veo 3: 8초 동영상 + 네이티브 오디오"
    
    # Gemini API 키
    api_key = ENV['GEMINI_API_KEY']
    
    if api_key.blank?
      puts "❌ GEMINI_API_KEY가 설정되지 않았습니다!"
      return
    end

    # 동영상 저장 디렉토리
    video_dir = Rails.root.join('public', 'videos', 'character_animations')
    FileUtils.mkdir_p(video_dir)

    # 표준 캐릭터 동영상 프롬프트
    character_videos = {
      # 정화 선생님 동영상 (슬라이드별)
      "jeonghwa_slide1_walking" => {
        prompt: "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly brown hair, blue cardigan, pearl necklace, black skirt. WALKING ANIMATION: Character walking naturally from left to right, then turning to face camera, then opening arms in welcoming gesture. Smooth natural movement, professional educator demeanor, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "jeonghwa_slide1_walking.mp4"
      },
      
      "jeonghwa_slide2_teaching" => {
        prompt: "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly brown hair, blue cardigan, pearl necklace, black skirt. TEACHING ANIMATION: Character making teaching gestures, pointing to content, nodding approvingly, professional educator movements, warm expression, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "jeonghwa_slide2_teaching.mp4"
      },
      
      "jeonghwa_slide3_proud" => {
        prompt: "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly brown hair, blue cardigan, pearl necklace, black skirt. PROUD PRESENTATION: Character presenting achievements proudly, gesturing with confidence, showing success results, satisfied and proud expression, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "jeonghwa_slide3_proud.mp4"
      },

      # 곰 학생 동영상 (슬라이드별)
      "bear_slide1_curious" => {
        prompt: "Cute friendly brown bear character animation with round ears and soft fur. CURIOUS EXPLORATION: Bear waddling curiously from side to front, tilting head with interest, leaning forward to look at content, nodding with understanding, adorable expressions, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "bear_slide1_curious.mp4"
      },
      
      "bear_slide2_studying" => {
        prompt: "Cute friendly brown bear character animation with round ears and soft fur. STUDYING BEHAVIOR: Bear focusing intently, nodding while learning, occasionally looking up with interest, thoughtful expressions, engaged student behavior, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "bear_slide2_studying.mp4"
      },
      
      "bear_slide3_celebrating" => {
        prompt: "Cute friendly brown bear character animation with round ears and soft fur. CELEBRATION DANCE: Bear doing a happy victory dance, raising paws in celebration, nodding with joy, expressing success and achievement, cheerful movements, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "bear_slide3_celebrating.mp4"
      },

      # 토끼 학생 동영상 (슬라이드별)  
      "rabbit_slide1_hopping" => {
        prompt: "Cute energetic white rabbit character animation with long ears and round tail. HOPPING SEQUENCE: Rabbit hopping energetically from right to left, ears bouncing naturally, landing gracefully, then turning to point excitedly at content, enthusiastic expressions, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "rabbit_slide1_hopping.mp4"
      },
      
      "rabbit_slide2_eager" => {
        prompt: "Cute energetic white rabbit character animation with long ears and round tail. EAGER LEARNING: Rabbit bouncing with excitement, raising paw to ask questions, ears perked up with interest, enthusiastic learning behavior, engaged student expressions, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "rabbit_slide2_eager.mp4"
      },
      
      "rabbit_slide3_victory" => {
        prompt: "Cute energetic white rabbit character animation with long ears and round tail. VICTORY CELEBRATION: Rabbit jumping with joy, doing victory hops, ears flying with excitement, celebrating success and achievements, pure happiness expressions, transparent background, 3D cartoon style like Pixar, seamless loop animation",
        filename: "rabbit_slide3_victory.mp4"
      }
    }

    # 각 동영상 생성
    character_videos.each_with_index do |(video_key, video_data), index|
      puts "\n🎬 [#{index + 1}/#{character_videos.size}] #{video_key} 동영상 생성 중..."
      
      video_path = video_dir.join(video_data[:filename])
      
      if File.exist?(video_path)
        puts "    ⏭️  이미 존재함: #{video_data[:filename]}"
        next
      end

      begin
        # 올바른 Gemini API 동영상 생성 (학습된 가이드 기반)
        uri = URI("https://generativelanguage.googleapis.com/v1beta/models/veo-3.0-generate-001:generateContent")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 300
        
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['x-goog-api-key'] = api_key
        
        # 올바른 요청 구조 (가이드 기반)
        payload = {
          contents: [{
            parts: [{
              text: video_data[:prompt]
            }]
          }],
          generationConfig: {
            aspectRatio: "1:1",
            resolution: "720p", 
            durationSeconds: 8,
            generateAudio: false
          }
        }
        
        request.body = payload.to_json
        
        puts "    📡 API 요청 중..."
        response = http.request(request)
        
        if response.code == '200'
          result = JSON.parse(response.body)
          puts "    📋 응답 확인: #{result.keys}"
          
          # Gemini API 응답 구조 확인
          if result['candidates'] && result['candidates'][0] && 
             result['candidates'][0]['content'] && 
             result['candidates'][0]['content']['parts']
            
            parts = result['candidates'][0]['content']['parts']
            video_part = parts.find { |part| part['videoData'] || part['inlineData'] }
            
            if video_part && video_part['inlineData']
              video_data = video_part['inlineData']['data']
              File.open(video_path, 'wb') do |file|
                file.write(Base64.decode64(video_data))
              end
              puts "    ✅ 동영상 생성 완료!"
            else
              puts "    ⏳ 동영상 생성 중... (비동기 처리)"
              puts "    📋 응답 구조: #{result}"
            end
          else
            puts "    ❌ 예상과 다른 응답 구조: #{result}"
          end
        else
          puts "    ❌ API 오류: #{response.code} - #{response.body}"
        end
        
      rescue => e
        puts "    ❌ 오류: #{e.message}"
        next
      end

      # API 제한 대응 (동영상 생성은 더 긴 대기 필요)
      sleep(10)
    end

    puts "\n🎉 캐릭터 애니메이션 동영상 생성 작업 완료!"
    puts "📁 저장 예정 위치: public/videos/character_animations/"
    puts "⏳ 동영상 생성 완료까지 시간이 소요될 수 있습니다."
    puts "💡 완료 후 HTML에서 <video> 태그로 사용하면 완벽한 루프 애니메이션이 가능합니다!"
  end

  desc "Compose alpha WebM from PNG frames using ffmpeg (fallback pipeline)"
  task :compose_webm, [:pattern, :output, :fps] => :environment do |t, args|
    require 'fileutils'
    pattern = args[:pattern] || Rails.root.join('app','assets','images','generated','character_animation','jeonghwa_3d_walk_%02d.png').to_s
    output  = args[:output]  || Rails.root.join('public','videos','character_animations','jeonghwa_walk.webm').to_s
    fps     = (args[:fps] || '12').to_s

    FileUtils.mkdir_p(File.dirname(output))
    cmd = "ffmpeg -y -framerate #{fps} -i '#{pattern}' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 2M '#{output}'"
    puts "🎞️  ffmpeg 합성 실행: #{cmd}"
    system(cmd)
    puts File.exist?(output) ? "✅ 합성 완료: #{output}" : "❌ 합성 실패"
  end
end
