require 'google/cloud/ai_platform/v1'

class VertexAiService
  attr_reader :client, :project_id, :location

  def initialize
    @project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'kicda-ai-project'
    @location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'
    
    # 서비스 계정 JSON 파일 경로 설정
    credentials_path = Rails.root.join('config', 'google_service_account.json')
    
    if File.exist?(credentials_path)
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
    else
      Rails.logger.error "Google service account JSON file not found at #{credentials_path}"
      raise "Google service account credentials not found"
    end
    
    initialize_client
  end

  # 이미지 생성 메서드 (Imagen 사용)
  def generate_image(prompt, style: 'modern', size: '1024x1024')
    begin
      # Imagen API 엔드포인트 구성
      endpoint = "projects/#{@project_id}/locations/#{@location}/publishers/google/models/imagegeneration@002"
      
      # 요청 페이로드 구성
      request = {
        instances: [
          {
            prompt: enhance_prompt(prompt, style)
          }
        ],
        parameters: {
          sampleCount: 1,
          aspectRatio: aspect_ratio_from_size(size),
          negativePrompt: "low quality, blurry, distorted, watermark"
        }
      }
      
      # API 호출
      response = predict(endpoint, request)
      
      # 생성된 이미지 처리
      if response && response.predictions.any?
        image_data = response.predictions.first['bytesBase64Encoded']
        save_generated_image(image_data, prompt)
      else
        Rails.logger.error "No image generated for prompt: #{prompt}"
        nil
      end
    rescue => e
      Rails.logger.error "Error generating image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  # 텍스트 기반 배너 생성
  def generate_banner(title, description, style: 'professional')
    prompt = build_banner_prompt(title, description, style)
    generate_image(prompt, style: style, size: '1920x600')
  end

  # 코스 썸네일 생성
  def generate_course_thumbnail(course_title, course_description)
    prompt = "Create an educational thumbnail for a course titled '#{course_title}'. 
              Description: #{course_description}. 
              Style: modern, professional, educational, clean design with relevant icons or imagery."
    
    generate_image(prompt, style: 'educational', size: '800x600')
  end

  private

  def initialize_client
    @client = ::Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
      config.endpoint = "#{@location}-aiplatform.googleapis.com"
    end
  rescue => e
    Rails.logger.error "Failed to initialize Vertex AI client: #{e.message}"
    raise
  end

  def predict(endpoint, request)
    @client.predict(
      endpoint: endpoint,
      instances: request[:instances],
      parameters: request[:parameters]
    )
  end

  def enhance_prompt(base_prompt, style)
    style_modifiers = {
      'modern' => 'modern, clean, minimalist, professional',
      'educational' => 'educational, informative, clear, engaging',
      'professional' => 'professional, corporate, polished, high-quality',
      'creative' => 'creative, artistic, vibrant, unique'
    }
    
    modifier = style_modifiers[style] || style_modifiers['modern']
    "#{base_prompt}. Style: #{modifier}"
  end

  def aspect_ratio_from_size(size)
    case size
    when '1920x600'
      '16:5'  # Banner ratio
    when '800x600'
      '4:3'   # Thumbnail ratio
    when '1024x1024'
      '1:1'   # Square ratio
    else
      '1:1'
    end
  end

  def build_banner_prompt(title, description, style)
    "Create a website banner with the title '#{title}' and subtitle '#{description}'. 
     The banner should be #{style} and suitable for an educational platform. 
     Include relevant visual elements but keep text readable and clear."
  end

  def save_generated_image(base64_data, prompt)
    # 이미지 데이터 디코딩
    image_data = Base64.decode64(base64_data)
    
    # 파일명 생성 (타임스탬프 + 프롬프트 일부)
    filename = "generated_#{Time.now.to_i}_#{prompt.parameterize.first(30)}.png"
    filepath = Rails.root.join('public', 'generated_images', filename)
    
    # 디렉토리 생성
    FileUtils.mkdir_p(File.dirname(filepath))
    
    # 파일 저장
    File.open(filepath, 'wb') do |file|
      file.write(image_data)
    end
    
    Rails.logger.info "Image saved: #{filepath}"
    "/generated_images/#{filename}"
  rescue => e
    Rails.logger.error "Failed to save image: #{e.message}"
    nil
  end
end
