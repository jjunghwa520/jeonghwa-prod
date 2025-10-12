# frozen_string_literal: true

namespace :thumbnails do
  desc "Generate course thumbnails using Vertex AI"
  task generate: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    
    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end
    
    unless project_id && cred_env && File.exist?(cred_env)
      puts "Vertex AI credentials not configured. Using placeholder thumbnails."
      generate_placeholder_thumbnails
      return
    end
    
    puts "\n=== Generating Thumbnails with Vertex AI ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 안전한 프롬프트 사용
    prompts = {
      'ebook' => [
        "Soft watercolor illustration of an open book with pastel pages, minimal style",
        "Abstract geometric book shape in purple and blue tones, modern design",
        "Minimalist book icon with soft gradient background, professional look",
        "Simple book silhouette with warm color palette, clean design",
        "Modern book illustration with abstract shapes, soft colors",
        "Geometric book design with pastel background, minimal style"
      ],
      'storytelling' => [
        "Abstract theater stage with soft lighting, minimal design",
        "Geometric curtain shapes in warm colors, modern style",
        "Simple stage spotlight illustration, professional look",
        "Minimalist performance space with abstract elements",
        "Modern theater design with soft gradients",
        "Abstract stage elements in pastel tones"
      ],
      'education' => [
        "Colorful pencil and brush illustration, minimal style",
        "Abstract art supplies in geometric shapes, modern design",
        "Simple creative tools with soft colors, professional look",
        "Minimalist education icons with warm palette",
        "Modern learning materials illustration, clean design",
        "Geometric stationery design with pastel background"
      ]
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'courses')
    FileUtils.mkdir_p(output_dir)
    
    negative = "people, face, character, animal, child, text, logo, watermark, photorealistic"
    
    prompts.each do |category, category_prompts|
      category_prompts.each_with_index do |prompt, index|
        filename = "#{category}_#{index + 1}.jpg"
        filepath = output_dir.join(filename)
        
        # 이미 생성된 파일은 건너뛰기
        if File.exist?(filepath) && File.size(filepath) > 0
          puts "  ✓ #{filename} already exists"
          next
        end
        
        puts "  → Generating #{filename}..."
        
        begin
          generator.generate!(
            prompt: prompt,
            filename: "courses/#{filename}",
            width: 400,
            height: 600,
            style_preset: "DIGITAL_ART",
            negative_prompt: negative
          )
          puts "  ✓ #{filename} generated"
        rescue => e
          puts "  ✗ #{filename} failed: #{e.message}"
          # 실패시 플레이스홀더 생성
          generate_single_placeholder(category, index + 1, filepath)
        end
        
        # API 제한 방지를 위한 딜레이
        sleep(1)
      end
    end
    
    puts "\n=== Thumbnail generation complete ==="
  end
  
  def generate_placeholder_thumbnails
    puts "\n=== Generating placeholder thumbnails ==="
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'courses')
    FileUtils.mkdir_p(output_dir)
    
    categories = ['ebook', 'storytelling', 'education']
    
    categories.each do |category|
      6.times do |i|
        filename = "#{category}_#{i + 1}.svg"
        filepath = output_dir.join(filename)
        generate_single_placeholder(category, i + 1, filepath)
        puts "  ✓ #{filename} placeholder created"
      end
    end
  end
  
  def generate_single_placeholder(category, index, filepath)
    colors = {
      'ebook' => ['#667eea', '#764ba2'],
      'storytelling' => ['#f093fb', '#f5576c'],
      'education' => ['#4facfe', '#00f2fe']
    }
    
    gradient = colors[category] || colors['ebook']
    icon = category == 'education' ? '✏️' : (category == 'storytelling' ? '🎭' : '📖')
    
    svg_content = <<~SVG
      <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="bg#{index}" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#{gradient[0]};stop-opacity:1" />
            <stop offset="100%" style="stop-color:#{gradient[1]};stop-opacity:1" />
          </linearGradient>
        </defs>
        <rect width="400" height="600" fill="url(#bg#{index})"/>
        <text x="200" y="300" text-anchor="middle" font-size="72" fill="white" opacity="0.3">#{icon}</text>
      </svg>
    SVG
    
    File.write(filepath, svg_content)
  end
end
