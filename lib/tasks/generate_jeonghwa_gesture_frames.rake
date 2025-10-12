namespace :jeonghwa_gesture do
  desc "Generate Jeonghwa gesture animation frames using successful Vertex AI Imagen"
  task generate: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || ENV["GOOGLE_CLOUD_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[jeonghwa_gesture:generate] Set project_id") unless project_id
    abort("[jeonghwa_gesture:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    puts "🎭 정화 제스처 애니메이션 프레임 생성 (성공한 Imagen 방식)"
    puts "🎯 동작: 오른쪽 걷기 → 정면 돌기 → 환영 제스처"

    # 안전한 네거티브 프롬프트
    negative = "text, typography, watermark, logo, brand, photorealistic, harsh lighting, busy composition, clutter, grain noise, different character, different clothing"

    # 정화 제스처 시퀀스 프레임
    gesture_frames = {
      "jeonghwa_gesture_walk_right" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING TO THE RIGHT: natural walking motion with right foot forward, left arm swinging naturally, side view showing leg movement, professional stride, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background, pedagogical character design for children's educational platform",
      
      "jeonghwa_gesture_turn_half" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, TURNING TO FACE VIEWER: body rotating from side view to three-quarter view, natural turning motion, transitional pose, warm expression, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_face_front" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, FACING CAMERA: front view with warm friendly smile, preparing to make welcoming gesture, professional posture, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_extend_hand" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WELCOMING GESTURE: right hand extended forward in inviting gesture, warm smile, 'come and see' expression, professional welcoming posture, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_complete" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, COMPLETE WELCOME: both arms slightly open in welcoming presentation, big warm smile, inviting and encouraging expression, professional educator demeanor, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 각 프레임 생성
    gesture_frames.each_with_index do |(filename, prompt), index|
      puts "\n📸 [#{index + 1}/#{gesture_frames.size}] #{filename} 생성 중..."
      
      begin
        # 성공한 Imagen 방식 사용
        path = generator.generate!(
          prompt: prompt,
          filename: "#{filename}.png",
          width: 1024,
          height: 1024,
          negative_prompt: negative
        )
        
        puts "    ✅ 생성 완료: #{path}"

      rescue => e
        puts "    ❌ 오류: #{e.message}"
        next
      end

      # API 제한 대응
      sleep(3)
    end

    puts "\n🎉 정화 제스처 프레임 생성 완료!"
    puts "📁 저장 위치: app/assets/images/generated/"
    puts "💡 다음 단계: FFmpeg로 비디오 합성"
  end
  
  desc "Compose gesture frames into WebM video"
  task compose: :environment do
    puts "🎞️ 정화 제스처 프레임들을 WebM으로 합성"
    
    # 생성된 프레임들 확인
    frame_files = [
      'app/assets/images/generated/jeonghwa_gesture_walk_right.png',
      'app/assets/images/generated/jeonghwa_gesture_turn_half.png', 
      'app/assets/images/generated/jeonghwa_gesture_face_front.png',
      'app/assets/images/generated/jeonghwa_gesture_extend_hand.png',
      'app/assets/images/generated/jeonghwa_gesture_complete.png'
    ]
    
    existing_frames = frame_files.select { |f| File.exist?(f) }
    puts "📋 사용 가능한 프레임: #{existing_frames.size}/#{frame_files.size}"
    
    if existing_frames.size >= 3
      # 임시 디렉토리에 순차적으로 복사
      temp_dir = '/tmp/jeonghwa_gesture_frames'
      FileUtils.mkdir_p(temp_dir)
      
      existing_frames.each_with_index do |frame, i|
        temp_frame = "#{temp_dir}/gesture_#{sprintf('%02d', i+1)}.png"
        FileUtils.cp(frame, temp_frame)
        puts "  복사: #{File.basename(frame)} → gesture_#{sprintf('%02d', i+1)}.png"
      end
      
      # 출력 경로
      output_path = 'public/videos/character_animations/jeonghwa_gesture_final.webm'
      FileUtils.mkdir_p(File.dirname(output_path))
      
      # FFmpeg 합성 (각 프레임 1.5초씩, 부드러운 속도)
      cmd = "ffmpeg -y -framerate 0.67 -i '#{temp_dir}/gesture_%02d.png' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 1.5M '#{output_path}'"
      
      puts "🎬 FFmpeg 실행: #{cmd}"
      system(cmd)
      
      if File.exist?(output_path)
        file_size = (File.size(output_path) / 1024.0).round(1)
        puts "✅ 제스처 동영상 완성: #{output_path} (#{file_size}KB)"
      else
        puts "❌ 비디오 합성 실패"
      end
      
      # 임시 파일 정리
      FileUtils.rm_rf(temp_dir)
      
    else
      puts "❌ 충분한 프레임이 없습니다. 먼저 generate 태스크를 실행하세요."
    end
  end
end

