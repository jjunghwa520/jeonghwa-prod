namespace :debug_vertex_policy do
  desc "Debug Vertex AI policy violations step by step"
  task analyze: :environment do
    project_id = ENV['VERTEX_PROJECT_ID'] || "gen-lang-client-0492798913"
    cred_env = ENV['GOOGLE_APPLICATION_CREDENTIALS'] || "config/google_service_account.json"
    
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    puts "🔍 Vertex AI 정책 위반 원인 분석 시작..."
    
    # 1단계: 기본 테스트 (이미 성공함을 확인)
    puts "\n1️⃣ 기본 안전 테스트:"
    basic_prompts = [
      "Beautiful landscape",
      "Colorful flowers in garden", 
      "Children's book illustration style"
    ]
    
    basic_prompts.each_with_index do |prompt, i|
      test_prompt(generator, prompt, "basic_#{i+1}.jpg")
    end
    
    # 2단계: 동물 키워드 테스트
    puts "\n2️⃣ 동물 키워드 테스트:"
    animal_prompts = [
      "Lion in meadow",
      "Friendly lion", 
      "Lion character",
      "Cartoon lion",
      "Lion illustration"
    ]
    
    animal_prompts.each_with_index do |prompt, i|
      test_prompt(generator, prompt, "animal_#{i+1}.jpg")
    end
    
    # 3단계: 판타지 키워드 테스트  
    puts "\n3️⃣ 판타지 키워드 테스트:"
    fantasy_prompts = [
      "Fairy in garden",
      "Magic forest",
      "Magical scene", 
      "Fantasy illustration",
      "Enchanted garden"
    ]
    
    fantasy_prompts.each_with_index do |prompt, i|
      test_prompt(generator, prompt, "fantasy_#{i+1}.jpg")
    end
    
    # 4단계: 조합 테스트
    puts "\n4️⃣ 조합 키워드 테스트:"
    combo_prompts = [
      "Lion in sunny meadow, children's book style",
      "Friendly animal character, cartoon style", 
      "Fantasy forest scene, illustration style",
      "Magical garden with flowers, watercolor style"
    ]
    
    combo_prompts.each_with_index do |prompt, i|
      test_prompt(generator, prompt, "combo_#{i+1}.jpg")
    end
    
    puts "\n🎉 정책 위반 분석 완료!"
  end
  
  private
  
  def test_prompt(generator, prompt, filename)
    print "  테스트: '#{prompt}' -> "
    begin
      generator.generate!(
        prompt: prompt,
        filename: filename,
        negative_prompt: "text, watermark"
      )
      puts "✅ 성공"
      true
    rescue => e
      if e.message.include?("58061214")
        puts "❌ 정책 위반"
      elsif e.message.include?("429")
        puts "⏸️ 할당량 초과"
      else
        puts "❌ 기타 오류: #{e.message[0..50]}..."
      end
      false
    end
  end
end
