namespace :title_specific_vertex do
  desc "Generate title-specific thumbnails via Vertex AI for each storybook"
  task generate: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[title_specific_vertex:generate] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[title_specific_vertex:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    # 매우 안전한 네거티브 프롬프트 (정책 위반 방지)
    negative = "text, typography, watermark, logo, brand, photorealistic, 3d render, harsh lighting, busy composition, clutter, grain noise"

    # 저장 디렉토리 생성
    title_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'title_specific_vertex')
    FileUtils.mkdir_p(title_dir)

    puts "🎨 제목별 맞춤 썸네일 생성 시작..."

    # 구체적이고 명확한 동화책 제목별 프롬프트 매핑 (캐릭터와 스토리 중심)
    title_prompts = {
      # 전자동화책 - 구체적인 캐릭터와 스토리 요소 포함
      "🦁 용감한 사자왕의 모험" => "Majestic golden lion with flowing mane standing proudly on rocky cliff, wearing royal crown, savanna background, brave heroic pose, watercolor illustration style",
      "🧚‍♀️ 마법 숲의 작은 요정" => "Tiny fairy with delicate wings sitting on mushroom, sparkling magic dust around her, enchanted forest with glowing flowers, whimsical digital art style",
      "🐰 달나라 토끼의 꿈" => "Cute white rabbit sitting on crescent moon, looking at Earth below, stars twinkling around, dreamy night sky, soft oil painting style",
      "🐻 곰돌이와 꿀벌 친구들" => "Friendly brown bear surrounded by buzzing bees near beehive, honey dripping from tree, sunny flower meadow, cheerful cartoon illustration",
      "🦊 여우의 지혜로운 선택" => "Clever red fox at forest crossroads with multiple paths, thoughtful expression, autumn leaves falling, wise and contemplative mood, traditional art style",
      "🐧 펭귄의 얼음나라 탐험" => "Adventurous penguin with backpack walking on ice floes, icebergs and aurora in background, arctic exploration scene, detailed sketch style",
      "🦋 나비의 아름다운 변신" => "Beautiful butterfly emerging from chrysalis on flower branch, transformation moment captured, vibrant spring garden, acrylic painting texture",
      "🐢 거북이의 느린 여행" => "Wise old turtle carrying small house on shell, walking slowly through peaceful meadow, journey and patience theme, soft pastel art",
      "🦉 부엉이의 밤 하늘 학교" => "Scholarly owl wearing glasses perched on tree branch, open books floating around, starry night classroom setting, vintage educational poster style",
      "🐿️ 다람쥐의 도토리 저금통" => "Busy squirrel collecting acorns in tree hollow, acorn savings pile visible, autumn oak tree setting, collage art with paper textures",

      # 구연동화 - 안전한 클래식 동화 프롬프트
      "🎭 백설공주와 일곱 난쟁이" => "Beautiful princess with black hair and red lips standing with seven small dwarfs in front of cozy forest cottage, fairy tale scene, medieval manuscript style",
      "🏰 신데렐라의 유리구두" => "Elegant glass slipper sparkling on marble palace steps, grand ballroom with chandeliers in background, magical midnight scene, Victorian fairy tale illustration",
      "🐺 빨간모자와 늑대" => "Little girl in red hooded cape walking through peaceful forest path, grandmother's cozy cottage visible in distance, friendly woodland atmosphere, German woodcut style",
      "🐷 아기돼지 삼형제" => "Three little pigs each building different houses - straw, wood, and brick houses side by side, countryside village setting, British storybook illustration",
      "🌹 미녀와 야수" => "Beautiful maiden in elegant dress dancing with gentle beast in enchanted castle ballroom, rose petals floating, romantic fairy tale scene, French baroque art style",
      "🐸 개구리 왕자" => "Green frog wearing tiny crown sitting on lily pad in peaceful pond, water lilies and lotus flowers around, magical transformation theme, Art Nouveau style",
      "👸 잠자는 숲속의 공주" => "Sleeping princess in tower bed surrounded by thorny rose vines, spinning wheel nearby, enchanted castle setting, Pre-Raphaelite painting style",
      "🏃 잭과 콩나무" => "Young boy standing next to enormous green beanstalk reaching up to clouds, magical castle visible above in clouds, adventure scene, Celtic illuminated manuscript style",
      "🍎 독이 든 사과" => "Shiny red apple with mysterious dark glow held by old witch's hand, magic mirror in background, dark fairy tale atmosphere, Gothic art style",
      "🦢 미운 오리 새끼" => "Graceful white swan swimming in peaceful lake with small duckling nearby, beautiful reflection in water, transformation theme, Japanese sumi-e ink painting style",

      # 동화만들기 교육 - 안전한 교육 테마 프롬프트
      "📝 동화 스토리 기획하기" => "Writer at desk with storyboard sketches, plot diagrams on wall, creative brainstorming session with story elements scattered around, modern flat design illustration",
      "🎨 동화 일러스트 그리기" => "Artist's workspace with paintbrushes, color palettes, half-finished character drawings, digital tablet showing fairy tale illustrations, vibrant pop art style",
      "📚 동화책 출판 완성하기" => "Printing press with colorful storybooks coming off production line, book binding station, finished books stacked ready for distribution, isometric technical illustration",
      "🏆 동화작가 마스터 과정" => "Accomplished author at award ceremony podium with golden trophy, published books displayed, literary achievement celebration, elegant art deco poster style",
      "✏️ 캐릭터 디자인 기초" => "Character design sheets showing fairy tale heroes in various poses and expressions, design process from sketch to final, professional concept art style",
      "🎭 대화문 작성법" => "Speech bubbles and dialogue examples floating around characters, conversation flow charts, storytelling communication techniques, modern infographic design",
      "🌈 색채 이론과 활용" => "Color wheel surrounded by paint swatches, artistic palette with vibrant hues, color harmony demonstrations, abstract expressionist painting style",
      "📖 제본과 인쇄 기초" => "Traditional bookbinding workshop with leather covers, golden tools, vintage printing equipment, craftsman hands working, steampunk industrial art style",
      "💡 창의적 발상법" => "Light bulb moments with creative ideas floating as visual elements, brainstorming mind map, imagination flowing into story concepts, surrealist dream-like composition",
      "🎪 동화책 전시회 준비" => "Gallery space with storybook displays, visitors admiring book art, professional exhibition setup with spotlights, contemporary museum art style",

      # 청소년 만화 콘텐츠 - 구체적인 캐릭터와 장면
      "🦸‍♂️ 히어로 아카데미아" => "Teenage superhero students in colorful uniforms training in modern academy courtyard, dynamic action poses with energy effects, manga illustration style",
      "🌟 별빛 소녀의 모험" => "Magical girl with starlight wand casting sparkles under night sky, flowing dress and long hair, celestial background with stars and moon, anime art style",
      "⚔️ 검술의 달인" => "Young swordsman in medieval armor holding gleaming sword, castle training grounds background, determined expression, detailed manga artwork",
      "🎮 게임 월드 서바이벌" => "Teenagers wearing VR headsets in futuristic gaming pods, digital world interface visible, cyberpunk neon lighting, sci-fi illustration style",
      "🏫 청춘 로맨스 스토리" => "High school students under cherry blossom tree, school uniforms, romantic spring atmosphere, shoujo manga soft art style",

      # 청소년 애니메이션 콘텐츠 - 고품질 애니메이션 장면
      "🎬 드래곤의 전설" => "Majestic dragon soaring over medieval castle with young knight on horseback below, epic fantasy landscape, cinematic anime style",
      "🌸 벚꽃 고등학교" => "Japanese high school building with pink cherry blossoms in full bloom, students walking to school, slice-of-life anime atmosphere",
      "🤖 로봇 파일럿" => "Giant mecha robot in action pose with teenage pilot visible in cockpit, futuristic city background, detailed mechanical design",
      "🏀 농구왕의 꿈" => "Basketball player mid-jump shooting ball toward hoop, sports court with cheering crowd, dynamic sports anime action scene",
      "🎭 연극부의 기적" => "Theater stage with spotlight on teenage actors performing, dramatic costumes and stage props, performing arts theme",

      # 새로 추가된 청소년 콘텐츠 - 웹툰/라이트노벨
      "📱 웹툰 스토리텔링 기법" => "Digital tablet showing webtoon panels and storyboard sketches, creative workspace with character designs, modern illustration style",
      "🎨 디지털 웹툰 그리기" => "Digital art studio with drawing tablet, stylus pen, and colorful webtoon characters on screen, professional digital art workspace",
      "📚 라이트노벨 창작 입문" => "Stack of light novels with anime-style covers, writing desk with manuscript pages, cozy reading corner with soft lighting",

      # 게임/코딩 카테고리
      "🎮 게임 기획 및 스토리 설계" => "Game development workspace with concept art, character designs, and game flow charts on wall, creative planning environment",
      "💻 스크래치로 시작하는 게임 코딩" => "Computer screen showing colorful Scratch programming interface with game sprites, educational coding environment",

      # 진로/자기계발 카테고리
      "🌟 청소년 진로 탐색" => "Career fair setting with various profession booths, teenagers exploring different job displays, bright educational atmosphere",
      "💪 청소년 자기계발 프로젝트" => "Study desk with goal-setting charts, planners, and motivational books, organized learning environment",
      "🎯 창의적 문제해결 워크숍" => "Workshop room with brainstorming boards, sticky notes, and teenagers working in teams, collaborative learning space",

      # 트렌드/문화 카테고리
      "📸 SNS 콘텐츠 크리에이터 되기" => "Content creation setup with camera, ring light, and smartphone for social media filming, modern creator workspace",
      "🎵 K-POP 댄스 안무 배우기" => "Dance studio with mirrors and colorful lighting, teenagers practicing choreography, energetic performance atmosphere",

      # 새로 추가된 청소년 샘플 콘텐츠
      # 웹툰 카테고리
      "📱 나만의 웹툰 캐릭터 만들기" => "Digital art workspace with character design sketches, drawing tablet, and colorful character sheets on desk",
      "🎨 웹툰 배경 그리기 마스터" => "Artist studio with perspective drawings, background artwork, and digital painting tools for webtoon creation",
      "📖 웹툰 스토리보드 제작법" => "Storyboard panels layout on desk with comic panels, speech bubbles, and narrative flow diagrams",

      # 라이트노벨 카테고리
      "📚 청소년 소설 쓰기 입문" => "Cozy writing desk with notebook, pen, and young adult novel books, warm reading atmosphere",
      "✨ 판타지 라이트노벨 창작" => "Fantasy writing workspace with magical elements, spell books, and mystical atmosphere for creative writing",
      "💕 로맨스 소설 쓰기 비법" => "Romantic writing setting with soft lighting, love story books, and heart-shaped decorations",

      # 댄스 카테고리
      "🎵 K-POP 기초 댄스 마스터" => "Modern dance studio with wooden floors, mirrors, and K-POP music equipment for dance practice",
      "💃 걸그룹 댄스 완전정복" => "Energetic dance studio with pink and purple lighting, girl group posters, and dance practice space",
      "🕺 보이그룹 댄스 챌린지" => "Dynamic dance studio with blue lighting, boy group choreography charts, and performance stage setup",

      # 크리에이터 카테고리 (엔터테인먼트)
      "📱 틱톡 바이럴 영상 만들기" => "Mobile video creation setup with ring light, smartphone on tripod, and trendy social media props",
      "🎬 유튜브 쇼츠 제작 마스터" => "YouTube content creation studio with professional camera, editing setup, and video production equipment",

      # 게임 카테고리
      "🎮 스크래치로 만드는 첫 게임" => "Computer screen showing Scratch programming interface with colorful code blocks and game sprites",
      "🕹️ 2D 플랫폼 게임 제작" => "Game development workspace with Unity interface, 2D character sprites, and level design tools",
      "🎯 게임 기획자 되기" => "Game design workspace with concept art, flowcharts, and game planning documents on multiple monitors",

      # 진로/자기계발 카테고리
      "🌟 나의 꿈 찾기 프로젝트" => "Career exploration workspace with job information books, aptitude test papers, and dream board",
      "💪 청소년 리더십 개발" => "Leadership workshop setting with teamwork activities, presentation boards, and group collaboration space",
      "📈 효과적인 학습법 마스터" => "Study optimization workspace with organized notes, time management tools, and effective learning materials",

      # 크리에이터 카테고리 (교육)
      "📸 인스타그램 마케팅 기초" => "Social media marketing workspace with smartphone, analytics charts, and Instagram content planning boards",
      "🎥 영상 편집 프로 되기" => "Professional video editing suite with multiple monitors, editing software, and video production equipment"
    }

    # 각 제목별로 썸네일 생성
    Course.all.each do |course|
      # 제목에서 이모지 제거하여 파일명 생성
      clean_title = course.title.gsub(/[^\w\s가-힣]/, '').strip.gsub(/\s+/, '_')
      filename = "#{clean_title}_#{course.id}.jpg"
      filepath = title_dir.join(filename)

      # 이미 존재하면 스킵
      if File.exist?(filepath)
        puts "⏭️  이미 존재: #{filename}"
        next
      end

      # 제목에 맞는 프롬프트 찾기
      prompt_base = title_prompts[course.title]
      
      if prompt_base.nil?
        puts "⚠️  프롬프트 없음: #{course.title}"
        next
      end

      puts "🖼️  생성 중: #{filename} (#{course.title})"

      # 카테고리별 스타일 추가
      category_style = case course.category
      when "전자동화책", "ebook"
        "Interactive digital storybook cover style, modern book illustration"
      when "구연동화", "storytelling"
        "Classic fairy tale illustration, traditional storybook art style"
      when "동화만들기", "education"
        "Educational workshop illustration, learning and creativity theme"
      else
        "Storybook illustration style"
      end

      # 구체적이고 명확한 최종 프롬프트 조합
      final_prompt = "#{prompt_base}. Storybook illustration, warm friendly atmosphere, soft lighting, gentle colors, high quality detailed artwork, clear recognizable elements"

      begin
        generator.generate!(
          prompt: final_prompt.strip,
          filename: filename,
          width: 400,
          height: 300,
          style_preset: "ILLUSTRATION",
          negative_prompt: negative
        )
        
        # 생성된 파일을 올바른 디렉토리로 이동
        source_path = Rails.root.join("app/assets/images/generated", filename)
        if File.exist?(source_path)
          FileUtils.mv(source_path, filepath)
        end
        puts "✅ 완료: #{filename}"
        
        # API 제한을 위한 대기
        sleep(2)
        
      rescue => e
        puts "❌ 실패: #{filename} - #{e.message}"
        # 실패해도 계속 진행
      end
    end

    puts "🎉 제목별 맞춤 썸네일 생성 완료!"
    puts "📁 저장 위치: #{title_dir}"
  end
end
