class ContentFileUploader
  class ValidationError < StandardError; end
  class FileError < StandardError; end

  VALID_IMAGE_EXTENSIONS = %w[.jpg .jpeg .png].freeze
  VALID_VIDEO_EXTENSIONS = %w[.mp4 .webm .m3u8].freeze
  VALID_CAPTION_EXTENSIONS = %w[.txt].freeze
  VALID_SUBTITLE_EXTENSIONS = %w[.vtt .srt].freeze
  VALID_HLS_EXTENSIONS = %w[.ts .m3u8].freeze

  MAX_IMAGE_SIZE = 10.megabytes
  MAX_VIDEO_SIZE = 500.megabytes
  MAX_CAPTION_SIZE = 100.kilobytes

  attr_reader :course, :content_type, :files, :errors, :uploaded_files

  def initialize(course:, content_type:, files:)
    @course = course
    @content_type = content_type
    @files = Array(files)
    @errors = []
    @uploaded_files = []
  end

  def upload
    validate_files!
    sort_files!
    check_duplicates!
    process_upload!
    
    { success: true, uploaded: @uploaded_files, errors: @errors }
  rescue ValidationError, FileError => e
    { success: false, uploaded: [], errors: [e.message] }
  end

  def validate_files!
    raise ValidationError, "파일이 없습니다" if @files.empty?
    raise ValidationError, "코스가 유효하지 않습니다" unless @course

    @files.each do |file|
      validate_file_type!(file)
      validate_file_size!(file)
      validate_file_name!(file)
    end
  end

  def sort_files!
    # 페이지 번호로 정렬 (page_001.jpg, page_002.jpg 등)
    @files.sort_by! do |file|
      filename = file.original_filename
      if filename =~ /page_(\d+)/
        $1.to_i
      else
        999999
      end
    end
  end

  def check_duplicates!
    existing_files = get_existing_files
    duplicates = []

    @files.each do |file|
      filename = file.original_filename
      if existing_files.include?(filename)
        duplicates << filename
      end
    end

    if duplicates.any?
      raise ValidationError, "중복 파일: #{duplicates.join(', ')}"
    end
  end

  def process_upload!
    dest_dir = get_destination_directory
    FileUtils.mkdir_p(dest_dir)

    @files.each do |file|
      begin
        filename = sanitize_filename(file.original_filename)
        dest_path = dest_dir.join(filename)
        
        File.open(dest_path, 'wb') do |f|
          f.write(file.read)
        end

        @uploaded_files << {
          filename: filename,
          path: dest_path.to_s.sub(Rails.root.join('public').to_s, ''),
          size: File.size(dest_path)
        }
      rescue => e
        @errors << "#{file.original_filename}: #{e.message}"
      end
    end

    raise FileError, "업로드 실패: #{@errors.join(', ')}" if @uploaded_files.empty?
  end

  private

  def validate_file_type!(file)
    ext = File.extname(file.original_filename).downcase
    
    valid = case @content_type
            when 'ebook_images'
              VALID_IMAGE_EXTENSIONS.include?(ext)
            when 'captions'
              VALID_CAPTION_EXTENSIONS.include?(ext)
            when 'video'
              VALID_VIDEO_EXTENSIONS.include?(ext)
            when 'subtitle'
              VALID_SUBTITLE_EXTENSIONS.include?(ext)
            when 'hls'
              VALID_HLS_EXTENSIONS.include?(ext)
            else
              false
            end

    unless valid
      raise ValidationError, "#{file.original_filename}: 지원하지 않는 파일 형식입니다"
    end
  end

  def validate_file_size!(file)
    size = file.size
    max_size = case @content_type
               when 'ebook_images'
                 MAX_IMAGE_SIZE
               when 'captions'
                 MAX_CAPTION_SIZE
               when 'video', 'hls'
                 MAX_VIDEO_SIZE
               else
                 MAX_IMAGE_SIZE
               end

    if size > max_size
      raise ValidationError, "#{file.original_filename}: 파일 크기 초과 (최대 #{max_size / 1.megabyte}MB)"
    end
  end

  def validate_file_name!(file)
    filename = file.original_filename
    
    # 페이지 파일 이름 검증
    if @content_type.in?(['ebook_images', 'captions'])
      unless filename =~ /^page_\d{3,4}\.(jpg|jpeg|png|txt)$/i
        raise ValidationError, "#{filename}: 파일명 형식이 올바르지 않습니다 (예: page_001.jpg)"
      end
    end
  end

  def sanitize_filename(filename)
    # 안전한 파일명으로 변환
    filename.gsub(/[^a-zA-Z0-9._-]/, '_')
  end

  def get_existing_files
    dest_dir = get_destination_directory
    return [] unless Dir.exist?(dest_dir)
    
    Dir.entries(dest_dir).reject { |f| f.start_with?('.') }
  end

  def get_destination_directory
    base = Rails.root.join('public')
    
    case @content_type
    when 'ebook_images', 'captions'
      base.join('ebooks', @course.id.to_s, 'pages')
    when 'video', 'subtitle', 'hls'
      base.join('videos', @course.id.to_s)
    else
      raise ValidationError, "지원하지 않는 콘텐츠 타입: #{@content_type}"
    end
  end
end

