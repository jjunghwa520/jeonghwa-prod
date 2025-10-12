namespace :test_vertex_simple do
  desc "Test Vertex AI with very simple prompts"
  task generate: :environment do
    project_id = ENV['VERTEX_PROJECT_ID']
    cred_env = ENV['GOOGLE_APPLICATION_CREDENTIALS']
    
    abort("[test_vertex_simple:generate] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[test_vertex_simple:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    # 매우 간단하고 안전한 테스트 프롬프트들
    test_prompts = [
      "Beautiful landscape with flowers",
      "Colorful garden scene", 
      "Peaceful meadow with trees",
      "Sunny day in nature",
      "Simple children's book illustration"
    ]

    test_prompts.each_with_index do |prompt, index|
      filename = "test_simple_#{index + 1}.jpg"
      puts "🖼️  테스트 중: #{filename} - '#{prompt}'"
      
      begin
        generator.generate!(
          prompt: prompt,
          filename: filename,
          negative_prompt: "text, watermark"
        )
        puts "✅ 성공: #{filename}"
        break # 하나만 성공하면 중단
      rescue => e
        puts "❌ 실패: #{filename} - #{e.message}"
      end
    end

    puts "🎉 Vertex AI 테스트 완료!"
  end
end
