# frozen_string_literal: true

module ImageHelper
  def generated_image_path(filename, fallback_type = nil)
    # 생성된 이미지 경로 확인
    generated_path = "generated/#{filename}"
    svg_path = "generated/#{filename.gsub(/\.(jpg|png)$/, '.svg')}"
    
    # 파일 존재 확인 (assets pipeline)
    if asset_exists?(generated_path)
      return image_path(generated_path)
    elsif asset_exists?(svg_path)
      return image_path(svg_path)
    end
    
    # 인라인 SVG 폴백
    return inline_svg_fallback(fallback_type) if fallback_type
    
    # 기본 placeholder
    'data:image/svg+xml;base64,' + Base64.encode64(default_placeholder_svg).gsub("\n", '')
  end
  
  def inline_svg_fallback(type)
    svg_content = case type
    when :hero
      SvgIllustrationGenerator.hero_background
    when :ebook
      SvgIllustrationGenerator.category_ebook
    when :storytelling
      SvgIllustrationGenerator.category_storytelling
    when :education
      SvgIllustrationGenerator.category_education
    else
      default_placeholder_svg
    end
    
    'data:image/svg+xml;base64,' + Base64.encode64(svg_content).gsub("\n", '')
  end
  
  def course_thumbnail_image(course, size = 'medium')
    category = course.category&.downcase || 'ebook'
    index = course.id % 6 + 1
    
    filename = "thumbnails/#{category}_#{index}.svg"
    generated_path = "generated/#{filename}"
    
    if asset_exists?(generated_path)
      image_path(generated_path)
    else
      # 동적 SVG 생성
      inline_svg_thumbnail(category, index)
    end
  end
  
  private
  
  def asset_exists?(path)
    # Rails asset pipeline에서 파일 존재 확인
    if Rails.application.assets
      Rails.application.assets.find_asset(path).present?
    else
      # Production에서는 manifest 확인
      Rails.application.assets_manifest.assets[path].present?
    end
  rescue
    false
  end
  
  def inline_svg_thumbnail(category, index)
    colors = thumbnail_color_palette(category, index)
    
    svg = <<~SVG
      <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <filter id="paper">
            <feTurbulence baseFrequency="0.02" numOctaves="3" seed="#{index}"/>
            <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.03 0"/>
          </filter>
        </defs>
        <rect width="400" height="600" fill="#{colors[0]}" filter="url(#paper)"/>
        <rect x="0" y="0" width="35" height="600" fill="#{colors[2]}" opacity="0.7"/>
        <circle cx="200" cy="250" r="80" fill="#{colors[1]}" opacity="0.2"/>
        <rect x="60" y="450" width="280" height="100" rx="8" fill="white" opacity="0.3"/>
      </svg>
    SVG
    
    'data:image/svg+xml;base64,' + Base64.encode64(svg).gsub("\n", '')
  end
  
  def thumbnail_color_palette(category, index)
    palettes = {
      'ebook' => [
        ['#E8F5E9', '#81C784', '#4CAF50'],
        ['#E3F2FD', '#64B5F6', '#2196F3']
      ],
      'storytelling' => [
        ['#FFF3E0', '#FFB74D', '#FF9800'],
        ['#FFEBEE', '#EF5350', '#F44336']
      ],
      'education' => [
        ['#E0F2F1', '#4DB6AC', '#009688'],
        ['#F1F8E9', '#AED581', '#8BC34A']
      ]
    }
    
    palettes[category]&.[](index % 2) || ['#F5F5F5', '#BDBDBD', '#757575']
  end
  
  def default_placeholder_svg
    <<~SVG
      <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
        <rect width="400" height="600" fill="#F5F5F5"/>
        <rect x="0" y="0" width="35" height="600" fill="#BDBDBD"/>
        <circle cx="200" cy="300" r="50" fill="#E0E0E0"/>
      </svg>
    SVG
  end
end
