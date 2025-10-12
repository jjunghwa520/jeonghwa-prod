namespace :jeonghwa do
  desc "Generate character announcement videos using Veo 3"
  task generate_announcement_videos: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    puts "🎬 캐릭터 공지사항 안내 영상 제작!"
    puts "🚶‍♀️ Veo 3로 캐릭터들이 걸어가며 안내하는 동적 영상"
    puts "📢 3가지 공지사항별 전용 영상"
    
    # 기존 Google Service Account를 사용하여 액세스 토큰 생성
    key_file_path = Rails.root.join('config', 'google_service_account.json')
    
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/generative-language']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      token['access_token']
    end

    # Veo 3 동영상 생성 함수 (Gemini API 통해 접근)
    def generate_veo_announcement_video(access_token, prompt, filename, options = {})
      aspect_ratio = options[:aspect_ratio] || "16:9"
      resolution = options[:resolution] || "720p"
      duration = options[:duration] || 8
      generate_audio = options[:generate_audio] != false
      
      # Vertex AI Video Generation API (올바른 엔드포인트)
      project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
      location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/veo-3.0-generate-001:predict")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 300
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}"
      
      # Vertex AI Video Generation 페이로드
      payload = {
        instances: [
          {
            prompt: prompt
          }
        ],
        parameters: {
          aspectRatio: aspect_ratio,
          resolution: resolution,
          durationSeconds: duration,
          generateAudio: generate_audio,
          safetyFilterLevel: "block_some"
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎬 Veo 3 영상 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..120]}..."
      puts "⚙️  설정: #{resolution}, #{aspect_ratio}, #{duration}초, 오디오: #{generate_audio ? '✅' : '❌'}"
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        # Vertex AI 응답 처리
        if result['predictions'] && result['predictions'][0]
          prediction = result['predictions'][0]
          
          # 동영상 데이터 확인
          if prediction['videoUri'] || prediction['bytesBase64Encoded']
            if prediction['videoUri']
              # 동영상 URI로 다운로드
              video_uri = URI(prediction['videoUri'])
              video_response = Net::HTTP.get_response(video_uri)
              
              if video_response.code == '200'
                output_dir = Rails.root.join('public', 'videos', 'character_announcements')
                FileUtils.mkdir_p(output_dir)
                
                file_path = File.join(output_dir, "#{filename}.mp4")
                File.open(file_path, 'wb') { |file| file.write(video_response.body) }
                
                puts "✅ 성공: #{filename}.mp4 (#{(video_response.body.size / 1024.0 / 1024.0).round(2)}MB)"
                return true
              else
                puts "❌ 실패: #{filename} - 동영상 다운로드 실패 (#{video_response.code})"
                return false
              end
            elsif prediction['bytesBase64Encoded']
              # Base64 인코딩된 동영상 데이터
              video_data = Base64.decode64(prediction['bytesBase64Encoded'])
              
              output_dir = Rails.root.join('public', 'videos', 'character_announcements')
              FileUtils.mkdir_p(output_dir)
              
              file_path = File.join(output_dir, "#{filename}.mp4")
              File.open(file_path, 'wb') { |file| file.write(video_data) }
              
              puts "✅ 성공: #{filename}.mp4 (#{(video_data.size / 1024.0 / 1024.0).round(2)}MB)"
              return true
            end
          else
            puts "❌ 실패: #{filename} - 동영상 데이터 없음"
            puts "📄 응답: #{prediction.inspect[0..200]}..."
            return false
          end
        else
          puts "❌ 실패: #{filename} - 예상치 못한 응답 구조"
          puts "📄 응답: #{result.inspect[0..300]}..."
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
      access_token = get_access_token(key_file_path)
      puts "🔑 Google Service Account 액세스 토큰 획득 완료"
      
      # 캐릭터 공지사항 안내 영상 프롬프트들
      announcement_video_prompts = {
        "jeonghwa_new_content_announcement" => {
          prompt: "A charming 3D animated sequence of a professional female educator with short curly hair wearing a blue blazer, starting from the left side of the screen and walking gracefully toward the center while gesturing enthusiastically toward floating text that says 'NEW CONTENT'. She holds a magical teaching wand that creates sparkles and floating book icons. Her expression is joyful and welcoming as she points to the announcement area. The background is a soft gradient that complements the educational theme. Camera follows her movement smoothly as she presents the new content announcement with professional enthusiasm.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        },
        
        "jeonghwa_education_announcement" => {
          prompt: "An engaging 3D animated scene featuring the same professional female educator walking confidently from left to center, this time holding educational materials and demonstrating teaching gestures. She approaches a floating 'EDUCATION PROGRAM' text banner while her magical wand creates educational symbols like pencils, books, and graduation caps. Her movements are purposeful and inspiring, showing her expertise in education. The camera captures her professional yet warm demeanor as she presents the educational opportunities with genuine excitement.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        },
        
        "jeonghwa_success_announcement" => {
          prompt: "A heartwarming 3D animated sequence showing the professional female educator walking proudly toward a 'SUCCESS STORIES' display, her expression beaming with pride and joy. She gestures toward floating testimonial cards and achievement badges while her magical wand creates celebratory effects like stars and confetti. Her body language conveys maternal pride in her students' accomplishments. The animation emphasizes her role as a mentor celebrating the growth and success of the children she has helped educate.",
          options: { resolution: "720p", duration: 8, generate_audio: true }
        },
        
        "students_reaction_video" => {
          prompt: "A delightful 3D animated scene featuring cute bear and rabbit student characters reacting excitedly to announcements. They start small in the background, then grow larger as they hop and jump with joy, pointing toward the announcement area. The bear character claps enthusiastically while the rabbit character bounces with excitement. Their movements are playful and childlike, creating a sense of wonder and anticipation. The animation shows their genuine enthusiasm for learning and new content.",
          options: { resolution: "720p", duration: 6, generate_audio: true }
        }
      }

      success_count = 0
      total_count = announcement_video_prompts.length

      announcement_video_prompts.each_with_index do |(filename, config), index|
        puts "━" * 70
        puts "🎬 캐릭터 안내 영상 생성 #{index + 1}/#{total_count}"
        
        if generate_veo_announcement_video(access_token, config[:prompt], filename, config[:options])
          success_count += 1
        end
        
        # 동영상 생성은 리소스 집약적이므로 간격을 둠
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 캐릭터 공지사항 안내 영상 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 안내 영상들:"
        Dir.glob(Rails.root.join('public', 'videos', 'character_announcements', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎬 캐릭터 안내 영상 특징:"
        puts "  - 8초 고품질 동영상 (720p)"
        puts "  - 네이티브 오디오 자동 생성"
        puts "  - 캐릭터가 실제로 걸어가며 안내"
        puts "  - 각 공지사항별 전용 영상"
        puts "  - 마법봉 효과와 교육적 제스처"
        puts "  - 학생들의 생동감 있는 반응"
        
        puts "\n💡 사용법:"
        puts "  히어로 섹션에서 <video> 태그로 재생"
        puts "  각 슬라이드별 해당 영상 자동 재생"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end
