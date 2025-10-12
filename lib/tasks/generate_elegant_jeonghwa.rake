namespace :elegant_jeonghwa do
  desc "Generate elegant Jeonghwa character with sophisticated dress"
  task generate: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || ENV["GOOGLE_CLOUD_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[elegant_jeonghwa:generate] Set project_id") unless project_id
    abort("[elegant_jeonghwa:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    puts "👗 우아한 정화 선생님 캐릭터 생성 (세련된 원피스)"

    # 안전한 네거티브 프롬프트
    negative = "inappropriate, revealing, tight, short, unprofessional, casual, childish, cartoon exaggeration, text, watermark"

    # 우아한 원피스 정화 캐릭터
    elegant_prompt = "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown. ELEGANT ATTIRE: wearing a sophisticated navy blue A-line midi dress with three-quarter sleeves, modest neckline, elegant silhouette, professional yet stylish appearance, pearl necklace accessory, comfortable low heels. POSE: standing gracefully with warm professional smile, confident educator posture, welcoming demeanor. STYLE: 3D cartoon style similar to Pixar animation, pedagogical character design for children's educational platform, isolated on transparent background, refined and tasteful design"

    begin
      puts "\n👗 우아한 원피스 정화 캐릭터 생성 중..."
      
      path = generator.generate!(
        prompt: elegant_prompt,
        filename: "jeonghwa_elegant_dress.png",
        width: 1024,
        height: 1024,
        negative_prompt: negative
      )
      
      puts "✅ 우아한 정화 캐릭터 생성 완료: #{path}"
      puts "📁 저장 위치: app/assets/images/generated/jeonghwa_elegant_dress.png"
      puts "💡 이제 히어로 섹션에 적용하겠습니다."

    rescue => e
      puts "❌ 오류: #{e.message}"
    end

    puts "\n🎉 우아한 정화 캐릭터 생성 작업 완료!"
  end
end

