namespace :jeonghwa do
  desc "Generate educational videos using Google Veo 3 video generation"
  task generate_veo_videos: :environment do
    require 'net/http'
    require 'json'
    require 'base64'

    puts "🎬 구글 Veo 3 동영상 생성 시작!"
    puts "🎵 특징: 8초 동영상 + 네이티브 오디오 생성"
    puts "📱 해상도: 720p, 1080p 지원"
    
    # Gemini API 키
    api_key = ENV['GEMINI_API_KEY'] || Rails.application.credentials.gemini_api_key
    
    if api_key.blank?
      puts "❌ GEMINI_API_KEY가 설정되지 않았습니다!"
      return
    end

    # Veo 3 동영상 생성 함수
    def generate_veo_video(api_key, prompt, filename, options = {})
      aspect_ratio = options[:aspect_ratio] || "16:9"
      resolution = options[:resolution] || "720p"
      duration = options[:duration] || 8
      generate_audio = options[:generate_audio] != false
      
      # Veo 3 동영상 생성 작업 시작
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/veo-3.0-generate-001:generateVideos?key=#{api_key}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 300  # 동영상 생성은 시간이 오래 걸림
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      
      payload = {
        prompt: prompt,
        config: {
          aspectRatio: aspect_ratio,
          resolution: resolution,
          durationSeconds: duration,
          generateAudio: generate_audio
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎬 Veo 3 동영상 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      puts "⚙️  설정: #{resolution}, #{aspect_ratio}, #{duration}초, 오디오: #{generate_audio ? '✅' : '❌'}"
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        # 작업 ID 추출
        if result['name']
          operation_id = result['name']
          puts "🔄 작업 시작됨: #{operation_id}"
          
          # 작업 완료까지 폴링
          max_attempts = 60  # 최대 10분 대기
          attempt = 0
          
          while attempt < max_attempts
            sleep(10)  # 10초마다 확인
            attempt += 1
            
            # 작업 상태 확인
            status_uri = URI("https://generativelanguage.googleapis.com/v1beta/#{operation_id}?key=#{api_key}")
            status_response = http.get(status_uri)
            
            if status_response.code == '200'
              status_result = JSON.parse(status_response.body)
              
              if status_result['done']
                if status_result['response'] && status_result['response']['generatedVideos']
                  video_data = status_result['response']['generatedVideos'][0]
                  
                  if video_data['videoUri']
                    # 동영상 다운로드
                    video_uri = URI(video_data['videoUri'])
                    video_response = Net::HTTP.get_response(video_uri)
                    
                    if video_response.code == '200'
                      output_dir = Rails.root.join('public', 'videos', 'jeonghwa')
                      FileUtils.mkdir_p(output_dir)
                      
                      file_path = File.join(output_dir, "#{filename}.mp4")
                      File.open(file_path, 'wb') { |file| file.write(video_response.body) }
                      
                      puts "✅ 성공: #{filename}.mp4 (#{(video_response.body.size / 1024.0 / 1024.0).round(2)}MB)"
                      return true
                    else
                      puts "❌ 실패: #{filename} - 동영상 다운로드 실패"
                      return false
                    end
                  else
                    puts "❌ 실패: #{filename} - 동영상 URI 없음"
                    return false
                  end
                elsif status_result['error']
                  puts "❌ 실패: #{filename} - #{status_result['error']['message']}"
                  return false
                else
                  puts "❌ 실패: #{filename} - 예상치 못한 응답"
                  return false
                end
              else
                puts "⏳ 진행 중... (#{attempt}/#{max_attempts})"
              end
            else
              puts "❌ 상태 확인 실패: HTTP #{status_response.code}"
              return false
            end
          end
          
          puts "⏰ 시간 초과: #{filename} - 작업이 완료되지 않았습니다"
          return false
        else
          puts "❌ 실패: #{filename} - 작업 ID 없음"
          return false
        end
      else
        error_body = JSON.parse(response.body) rescue response.body
        puts "❌ 실패: #{filename} - HTTP #{response.code}"
        puts "📄 오류: #{error_body.dig('error', 'message') || error_body}"
        return false
      end
    rescue => e
      puts "❌ 예외: #{filename} - #{e.message}"
      return false
    end

    begin
      puts "🔑 Gemini API 키 확인 완료\n"
      
      # 정화의 서재 교육 동영상 프롬프트
      veo_video_prompts = {
        "jeonghwa_intro_video" => {
          prompt: "A warm and friendly 3D animated sequence showing a professional female educator in a bright blue blazer welcoming viewers to an educational library setting. She has short curly hair and a gentle smile, standing in a cozy room filled with colorful children's books. The camera slowly zooms in as she waves hello and gestures toward the books with enthusiasm. Soft, warm lighting creates an inviting atmosphere perfect for children's education.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        },
        
        "jeonghwa_teaching_video" => {
          prompt: "An engaging 3D animated scene of a professional female educator demonstrating storytelling techniques. She wears a blue cardigan and holds a colorful storybook, using expressive gestures as she reads. The background shows a bright classroom with educational posters and floating magical elements like sparkles and gentle book pages. The animation emphasizes her warm, motherly teaching style with smooth movements and inviting expressions.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        },
        
        "jeonghwa_story_time" => {
          prompt: "A delightful 3D animated sequence featuring a nurturing female educator sitting comfortably while reading from a magical storybook. As she reads, illustrated characters and scenes emerge from the book in gentle, floating animations. She has short wavy hair, wears a soft blue jacket, and maintains a warm, engaging expression throughout. The scene transitions from reality to a whimsical storybook world with pastel colors.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        }
      }

      success_count = 0
      total_count = veo_video_prompts.length

      veo_video_prompts.each_with_index do |(filename, config), index|
        puts "━" * 70
        puts "🎬 Veo 3 동영상 생성 #{index + 1}/#{total_count}"
        
        if generate_veo_video(api_key, config[:prompt], filename, config[:options])
          success_count += 1
        end
        
        # 동영상 생성은 리소스 집약적이므로 간격을 둠
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 Veo 3 교육 동영상 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 동영상들:"
        Dir.glob(Rails.root.join('public', 'videos', 'jeonghwa', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎬 Veo 3 동영상 특징:"
        puts "  - 8초 고품질 동영상"
        puts "  - 네이티브 오디오 자동 생성"
        puts "  - 720p/1080p 해상도 지원"
        puts "  - 24fps 프레임 레이트"
        puts "  - 교육용 콘텐츠 최적화"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

