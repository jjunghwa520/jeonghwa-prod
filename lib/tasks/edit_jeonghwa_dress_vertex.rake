namespace :jeonghwa_dress do
  desc "Edit Jeonghwa character outfit using Vertex AI Imagen (maintaining character consistency)"
  task edit: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || ENV["GOOGLE_CLOUD_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[jeonghwa_dress:edit] Set project_id") unless project_id
    abort("[jeonghwa_dress:edit] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    puts "👗 정화 캐릭터 의상 변경 (Vertex AI Imagen)"
    puts "🎯 기존 캐릭터 스타일 완전 유지 + 우아한 원피스로 변경"

    # 안전한 네거티브 프롬프트
    negative = "photorealistic, realistic, different face, different hair, different character, adult photo, inappropriate, revealing, tight, short, different art style, 3d render, text, watermark"

    # 기존 캐릭터 스타일 유지하면서 의상만 변경
    dress_edit_prompt = "Educational illustration of a professional middle-aged female educator character with EXACT SAME cartoon/anime art style as typical children's book illustration. MAINTAIN EXACTLY: East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, same cartoon face and expression, same pose and body proportions. CHANGE ONLY CLOTHING: elegant navy blue A-line midi dress with 3/4 sleeves instead of cardigan and skirt, keep pearl necklace accessory, professional yet stylish appearance. STYLE: 3D cartoon style similar to Pixar animation, children's book illustration style, pedagogical character design, isolated on transparent background, maintain exact same art style and character consistency"

    begin
      puts "\n👗 의상 편집 중..."
      
      path = generator.generate!(
        prompt: dress_edit_prompt,
        filename: "jeonghwa_cartoon_dress.png",
        width: 1024,
        height: 1024,
        negative_prompt: negative
      )
      
      puts "✅ 카툰 스타일 원피스 정화 생성 완료: #{path}"

    rescue => e
      puts "❌ 오류: #{e.message}"
    end

    puts "\n🎉 정화 의상 편집 작업 완료!"
    puts "💡 카툰 스타일을 유지하면서 우아한 원피스로 변경됨"
  end
end

