# frozen_string_literal: true

require 'net/http'
require 'json'
require 'open-uri'

class UnsplashImageDownloader
  BASE_URL = 'https://api.unsplash.com'
  
  def initialize
    @access_key = ENV['UNSPLASH_ACCESS_KEY'] || 'demo' # Unsplash provides demo access
  end

  def search_and_download(query:, filename:, width: 1920, height: 920)
    # Unsplash API 검색
    search_url = "#{BASE_URL}/search/photos?query=#{URI.encode_www_form_component(query)}&orientation=landscape&per_page=1"
    
    begin
      uri = URI(search_url)
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Client-ID #{@access_key}"
      
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      
      if res.code == '200'
        data = JSON.parse(res.body)
        if data['results'] && data['results'].any?
          photo = data['results'].first
          download_url = photo['urls']['raw'] + "&w=#{width}&h=#{height}&fit=crop"
          
          # 이미지 다운로드 및 저장
          save_image(download_url, filename)
          return true
        end
      end
    rescue => e
      Rails.logger.error "Unsplash download failed: #{e.message}"
    end
    
    false
  end

  def download_curated_images
    # 큐레이션된 고품질 이미지 다운로드
    images = {
      'hero_main.jpg' => 'warm pastel illustration children book background',
      'category_ebook.jpg' => 'soft pastel book pages abstract',
      'category_storytelling.jpg' => 'theater stage curtain warm colors',
      'category_education.jpg' => 'art supplies pastel colors creative'
    }
    
    images.each do |filename, query|
      if search_and_download(query: query, filename: filename)
        puts "✓ Downloaded: #{filename}"
      else
        puts "✗ Failed to download: #{filename}"
        # SVG 폴백 생성
        generate_svg_fallback(filename)
      end
    end
  end

  private

  def save_image(url, filename)
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated')
    FileUtils.mkdir_p(output_dir)
    
    output_path = output_dir.join(filename)
    
    URI.open(url) do |image|
      File.open(output_path, 'wb') do |file|
        file.write(image.read)
      end
    end
    
    puts "✓ Saved: #{output_path}"
  end

  def generate_svg_fallback(filename)
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated')
    FileUtils.mkdir_p(output_dir)
    
    # SVG 일러스트레이션 생성
    svg_content = case filename
    when 'hero_main.jpg'
      SvgIllustrationGenerator.hero_background
    when 'category_ebook.jpg'
      SvgIllustrationGenerator.category_ebook
    when 'category_storytelling.jpg'
      SvgIllustrationGenerator.category_storytelling
    when 'category_education.jpg'
      SvgIllustrationGenerator.category_education
    else
      SvgIllustrationGenerator.book_cover_placeholder
    end
    
    # SVG를 파일로 저장
    svg_filename = filename.gsub('.jpg', '.svg')
    output_path = output_dir.join(svg_filename)
    
    File.write(output_path, svg_content)
    puts "✓ Generated SVG fallback: #{output_path}"
  end
end
