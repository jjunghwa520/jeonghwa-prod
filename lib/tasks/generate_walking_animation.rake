namespace :walking_animation do
  desc "Generate walking animation frames using successful Vertex AI method"
  task generate: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[walking_animation:generate] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[walking_animation:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    # 안전한 네거티브 프롬프트
    negative = "text, typography, watermark, logo, brand, photorealistic, 3d render, harsh lighting, busy composition, clutter, grain noise"

    # 저장 디렉토리 생성
    animation_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'character_animation')
    FileUtils.mkdir_p(animation_dir)

    puts "🎭 실제 걷기 애니메이션 프레임 생성 시작..."

    # 정화 선생님 걷기 애니메이션 프레임 (성공한 방식 적용)
    jeonghwa_frames = {
      "jeonghwa_walk_1" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING ANIMATION FRAME 1: right foot stepping forward, left foot behind, right arm swinging forward naturally, side view showing leg movement, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background, pedagogical character design for children's educational platform",
      
      "jeonghwa_walk_2" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING ANIMATION FRAME 2: both feet on ground, body weight shifting, arms in middle swing position, natural walking motion, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_turn_front" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, TURNING TO FACE VIEWER: body rotating from side view to front view, natural turning motion, warm friendly smile, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_welcome" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WELCOMING GESTURE: both arms opened wide in welcoming presentation gesture, big warm smile, inviting posture, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 곰 학생 뒤뚱거리기 애니메이션
    bear_frames = {
      "bear_waddle_1" => "Cute friendly brown bear character with round ears and soft fur, WADDLING ANIMATION FRAME 1: leaning to the left, right paw lifted slightly off ground, characteristic bear waddle, adorable expression, 3D cartoon style similar to Pixar animation, isolated on transparent background, educational mascot design",
      
      "bear_waddle_2" => "Cute friendly brown bear character with round ears and soft fur, WADDLING ANIMATION FRAME 2: stepping forward with right paw, body shifting to center, natural bear walking motion, friendly expression, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "bear_curious" => "Cute friendly brown bear character with round ears and soft fur, CURIOUS EXPRESSION: leaning forward with interest, neck extended, eyes wide with curiosity, engaged and alert posture, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 토끼 학생 깡총깡총 애니메이션  
    rabbit_frames = {
      "rabbit_hop_prep" => "Cute energetic white rabbit character with long ears and round tail, HOPPING ANIMATION FRAME 1: crouched down with hind legs bent deeply, front paws on ground, preparing to jump with coiled energy, excited expression, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "rabbit_hop_air" => "Cute energetic white rabbit character with long ears and round tail, HOPPING ANIMATION FRAME 2: fully airborne with all paws tucked under body, ears flowing back from wind, peak of jump motion, joyful expression, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "rabbit_hop_land" => "Cute energetic white rabbit character with long ears and round tail, HOPPING ANIMATION FRAME 3: landing with front paws first touching ground, hind legs still in air, absorbing impact gracefully, happy expression, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 모든 프레임 생성
    all_frames = jeonghwa_frames.merge(bear_frames).merge(rabbit_frames)
    
    all_frames.each_with_index do |(filename, prompt), index|
      puts "\n📸 [#{index + 1}/#{all_frames.size}] #{filename} 생성 중..."
      
      image_path = animation_dir.join("#{filename}.jpg")
      
      if File.exist?(image_path)
        puts "    ⏭️  이미 존재함"
        next
      end

      begin
        # 성공한 방식 그대로 사용 (올바른 메서드명)
        generator.generate!(
          prompt: prompt,
          filename: filename,
          width: 1024,
          height: 1024,
          negative_prompt: negative
        )
        
        puts "    ✅ 생성 완료!"

      rescue => e
        puts "    ❌ 오류: #{e.message}"
        next
      end

      # API 제한 대응
      sleep(2)
    end

    puts "\n🎉 걷기 애니메이션 프레임 생성 완료!"
    puts "📁 저장 위치: app/assets/images/generated/character_animation/"
  end
end
