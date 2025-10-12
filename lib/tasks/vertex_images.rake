namespace :vertex do
  desc "Generate homepage images via Vertex AI and save under app/assets/images/generated"
  task generate_images: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"]
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "gen-lang-client-0492798913-03180bcdbcef.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[vertex:generate_images] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[vertex:generate_images] Set VERTEX_CREDENTIALS or GOOGLE_APPLICATION_CREDENTIALS env, or place JSON in config/.") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)

    negative = "text, typography, watermark, logo, brand, people, face, character, animal, kid, child, children, photorealistic, 3d render, gradient, neon, harsh contrast, busy composition, clutter, grain noise"

    puts "→ Generating hero image..."
    prompt_hero = <<~PROMPT
      Abstract geometric pattern with soft organic shapes for website background.
      Muted purple and blue tones with warm accents. Subtle paper texture overlay.
      Simple circular and curved elements suggesting movement and flow.
      Professional, modern, minimal design suitable for digital platform.
      Abstract only, no recognizable objects or figures.
    PROMPT
    begin
      generator.generate!(
        prompt: prompt_hero.strip,
        filename: "hero_main.jpg",
        width: 1920,
        height: 920,
        style_preset: "ILLUSTRATION",
        negative_prompt: negative
      )
    rescue => e
      puts "WARN hero generation skipped: #{e.message}"
    end

    puts "→ Generating category images..."
    prompt_ebook = <<~PROMPT
      Editorial cover-like abstract banner illustration.
      Warm pastel cream/ivory/sage with a deep navy accent. Layered page shapes and a vertical spine.
      Paper grain, subtle ink lines, gentle stipple texture, generous whitespace.
      Flat colors (no gradients or neon). No text/logos/brands, no people/faces, no animals, no characters,
      no children, no photorealism.
    PROMPT
    begin
      generator.generate!(
        prompt: prompt_ebook.strip,
        filename: "category_ebook.jpg",
        width: 1600,
        height: 600,
        style_preset: "ILLUSTRATION",
        negative_prompt: negative
      )
    rescue => e
      puts "WARN ebook banner skipped: #{e.message}"
    end

    prompt_story = <<~PROMPT
      Stage-themed editorial abstract banner illustration.
      Warm amber/terracotta/coral palette in flat colors (no gradients or neon).
      Soft curtain-like curves and a subtle spotlight circle, small star and ribbon silhouettes.
      Watercolor/gouache-like texture with clean spacing.
      No text/logos/brands, no people/faces, no animals, no characters, no children, no photorealism.
    PROMPT
    begin
      generator.generate!(
        prompt: prompt_story.strip,
        filename: "category_storytelling.jpg",
        width: 1600,
        height: 600,
        style_preset: "ILLUSTRATION",
        negative_prompt: negative
      )
    rescue => e
      puts "WARN storytelling banner skipped: #{e.message}"
    end

    prompt_edu = <<~PROMPT
      Creative workshop editorial abstract banner illustration.
      Cozy mint/sage/ivory palette in flat colors. Pencil/pastel strokes and paper-collage textures,
      simple stamp dots and clean whitespace.
      No text/logos/brands, no people/faces, no animals, no characters, no children, no photorealism.
    PROMPT
    begin
      generator.generate!(
        prompt: prompt_edu.strip,
        filename: "category_education.jpg",
        width: 1600,
        height: 600,
        style_preset: "ILLUSTRATION",
        negative_prompt: negative
      )
    rescue => e
      puts "WARN education banner skipped: #{e.message}"
    end

    puts "✓ All images generated under app/assets/images/generated"
  end
end
