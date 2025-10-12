# frozen_string_literal: true

namespace :kids do
  desc "Generate kids-friendly thumbnails using Vertex AI"
  task generate_thumbnails: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    
    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end
    
    unless project_id && cred_env && File.exist?(cred_env)
      puts "Vertex AI credentials not configured."
      return
    end
    
    puts "\n=== Generating Kids-Friendly Thumbnails ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 안전하고 밝은 프롬프트 (children 단어 제거)
    prompts = {
      'ebook' => [
        "Colorful storybook cover illustration, cute cartoon style, bright pastel colors, whimsical fantasy scene",
        "Magical storybook illustration with rainbow and clouds, soft watercolor style, cheerful and bright",
        "Friendly cartoon castle with smiling sun, vibrant happy colors, fantasy art style",
        "Cute forest scene with butterflies and flowers, soft and dreamy atmosphere, pastel illustration",
        "Playful underwater scene with colorful fish, bright ocean colors, cartoon style",
        "Happy garden with rainbow and butterflies, warm and inviting, storybook illustration"
      ],
      'storytelling' => [
        "Colorful puppet show stage, bright curtains and spotlights, theatrical illustration",
        "Magical circus tent with stars, festive and joyful colors, entertainment theme",
        "Cartoon theater stage with red curtains, warm and inviting performance space",
        "Whimsical performance stage with rainbow lights, bright and cheerful atmosphere",
        "Friendly puppet theater scene, soft pastel colors, entertainment art",
        "Colorful stage with confetti and balloons, celebration theme, party illustration"
      ],
      'education' => [
        "Bright art supplies and rainbow colors, fun learning theme, creative illustration",
        "Colorful crayons and paintbrush, creative and playful art class theme",
        "Happy classroom with ABC blocks, bright learning environment illustration",
        "Cheerful art studio with rainbow palette, inspiring colors, creativity theme",
        "Playful learning tools and shapes, bright and engaging educational art",
        "Colorful craft supplies and stars, creative fun theme, DIY illustration"
      ]
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'kids')
    FileUtils.mkdir_p(output_dir)
    
    # 아이들에게 안전한 네거티브 프롬프트
    negative = "scary, dark, violent, sad, realistic photo, adult content, text, logo"
    
    success_count = 0
    
    prompts.each do |category, category_prompts|
      category_prompts.each_with_index do |prompt, index|
        filename = "#{category}_#{index + 1}.jpg"
        filepath = output_dir.join(filename)
        
        puts "  → Generating #{filename}..."
        
        begin
          generator.generate!(
            prompt: prompt,
            filename: "kids/#{filename}",
            width: 400,
            height: 600,
            style_preset: "DIGITAL_ART",
            negative_prompt: negative
          )
          puts "  ✓ #{filename} generated"
          success_count += 1
        rescue => e
          puts "  ✗ #{filename} failed: #{e.message}"
        end
        
        # API 제한 방지
        sleep(2)
      end
    end
    
    puts "\n=== Generated #{success_count} thumbnails successfully ==="
    
    # 히어로 배경도 새로 생성
    puts "\n→ Generating kids hero background..."
    begin
      generator.generate!(
        prompt: "Magical storybook fantasy landscape with rainbow, floating clouds, hot air balloons, pastel colors, whimsical scene, bright and cheerful, soft illustration style",
        filename: "kids/hero_kids.jpg",
        width: 1920,
        height: 920,
        style_preset: "DIGITAL_ART",
        negative_prompt: negative
      )
      puts "  ✓ Hero background generated"
    rescue => e
      puts "  ✗ Hero background failed: #{e.message}"
    end
  end
end
