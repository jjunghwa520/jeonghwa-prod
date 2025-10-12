namespace :standard_characters do
  desc "Generate animation frames for standard characters only"
  task generate_animations: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[standard_characters:generate_animations] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[standard_characters:generate_animations] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    negative = "text, typography, watermark, logo, brand, photorealistic, 3d render, harsh lighting, busy composition, clutter, grain noise"

    # 저장 디렉토리 생성
    std_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'standard_characters')
    FileUtils.mkdir_p(std_dir)

    puts "🎭 표준 캐릭터 애니메이션 프레임 생성 시작..."

    # 정화 선생님 표준 애니메이션 프레임
    jeonghwa_animations = {
      # 걷기 사이클 (4프레임)
      "jeonghwa_walk_frame_1" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING FRAME 1: right foot forward, left foot back, right arm swinging forward, natural walking stride, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_walk_frame_2" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING FRAME 2: both feet on ground, body weight shifting, arms in neutral position, mid-stride walking motion, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_walk_frame_3" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING FRAME 3: left foot forward, right foot back, left arm swinging forward, opposite stride from frame 1, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_walk_frame_4" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WALKING FRAME 4: both feet on ground again, completing walking cycle, arms swinging naturally, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      # 방향 전환 (3프레임)
      "jeonghwa_turn_side" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, SIDE PROFILE VIEW: complete side view looking left, body facing sideways, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_turn_half" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, TURNING MOTION: 45-degree angle, body rotating towards viewer, face partially visible, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_turn_front" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, FRONT FACING: complete front view, body fully facing viewer, warm friendly smile, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      # 제스처 (3프레임)
      "jeonghwa_gesture_start" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, GESTURE START: arms at sides, neutral position, preparing to gesture, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_extend" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, GESTURE EXTEND: right arm extending outward, presenting gesture, professional educator pose, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "jeonghwa_gesture_welcome" => "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt, WELCOME GESTURE: both arms opened wide, welcoming presentation gesture, big warm smile, full body standing pose, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 곰 학생 표준 애니메이션 프레임
    bear_animations = {
      "bear_waddle_left" => "Cute friendly brown bear character with round ears and soft fur, exactly matching the existing bear design, WADDLING LEFT: bear leaning to the left side, right paw slightly lifted, characteristic bear waddle motion, adorable expression, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "bear_waddle_right" => "Cute friendly brown bear character with round ears and soft fur, exactly matching the existing bear design, WADDLING RIGHT: bear leaning to the right side, left paw slightly lifted, opposite lean from left waddle, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "bear_curious_lean" => "Cute friendly brown bear character with round ears and soft fur, exactly matching the existing bear design, CURIOUS LEAN: bear leaning forward with neck extended, showing interest and curiosity, eyes wide and engaged, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "bear_nod_happy" => "Cute friendly brown bear character with round ears and soft fur, exactly matching the existing bear design, HAPPY NOD: bear nodding head with satisfied expression, showing understanding and agreement, friendly demeanor, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 토끼 학생 표준 애니메이션 프레임  
    rabbit_animations = {
      "rabbit_crouch_prep" => "Cute energetic white rabbit character with long ears and round tail, exactly matching the existing rabbit design, HOP PREPARATION: rabbit crouched down low, hind legs bent deeply, front paws on ground, coiled energy ready to jump, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "rabbit_mid_jump" => "Cute energetic white rabbit character with long ears and round tail, exactly matching the existing rabbit design, MID JUMP: rabbit fully airborne, all paws tucked under body, ears flowing back, peak of hopping motion, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "rabbit_land_front" => "Cute energetic white rabbit character with long ears and round tail, exactly matching the existing rabbit design, LANDING: rabbit landing with front paws touching ground first, hind legs still in air, graceful landing motion, 3D cartoon style similar to Pixar animation, isolated on transparent background",
      
      "rabbit_excited_ears" => "Cute energetic white rabbit character with long ears and round tail, exactly matching the existing rabbit design, EXCITED EARS: rabbit with ears perked up high, showing excitement and interest, alert and enthusiastic expression, 3D cartoon style similar to Pixar animation, isolated on transparent background"
    }

    # 모든 프레임 생성
    all_animations = jeonghwa_animations.merge(bear_animations).merge(rabbit_animations)
    
    all_animations.each_with_index do |(filename, prompt), index|
      puts "\n📸 [#{index + 1}/#{all_animations.size}] #{filename} 생성 중..."
      
      begin
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
      sleep(3)
    end

    puts "\n🎉 표준 캐릭터 애니메이션 프레임 생성 완료!"
    puts "📁 저장 위치: app/assets/images/generated/standard_characters/"
  end
end

