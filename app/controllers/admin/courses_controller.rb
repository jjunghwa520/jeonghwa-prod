module Admin
  class CoursesController < BaseController
    before_action :set_course, only: [:show, :edit, :update, :destroy, :upload_files, :delete_file]
    
    def index
      @courses = Course.includes(:instructor, :enrollments, :reviews)
      
      # 검색
      if params[:search].present?
        @courses = @courses.search(params[:search])
      end
      
      # 카테고리 필터
      if params[:category].present?
        @courses = @courses.by_category(params[:category])
      end
      
      # 상태 필터
      if params[:status].present?
        @courses = @courses.where(status: params[:status])
      end
      
      # 정렬
      case params[:sort]
      when 'popular'
        @courses = @courses.left_joins(:enrollments)
                          .group('courses.id')
                          .order('COUNT(enrollments.id) DESC')
      when 'price'
        @courses = @courses.order(price: :asc)
      else # 'recent' 또는 기본값
        @courses = @courses.order(created_at: :desc)
      end
      
      @courses = @courses.limit(100)
      
      # 각 코스의 콘텐츠 상태 확인
      @content_status = {}
      @courses.each do |course|
        pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
        video_dir = Rails.root.join('public', 'videos', course.id.to_s)
        
        page_count = Dir.glob(pages_dir.join('page_*.{jpg,png}')).count
        has_video = File.exist?(video_dir.join('index.m3u8')) || 
                    File.exist?(video_dir.join('main.mp4'))
        
        status = determine_status(course, page_count, has_video)
        
        @content_status[course.id] = {
          page_count: page_count,
          has_video: has_video,
          status: status
        }
      end
      
      # 콘텐츠 상태 필터 (메모리에서 필터링)
      if params[:content_status].present?
        @courses = @courses.select do |course|
          @content_status[course.id][:status] == params[:content_status]
        end
      end
    end

    def new
      @course = Course.new
      @authors = Author.active.order(:name)
    end

    def create
      @course = Course.new(course_params)
      @course.instructor = current_user
      
      begin
        ActiveRecord::Base.transaction do
          if @course.save
            # 작가 정보 추가
            attach_authors(@course, params[:course])
            
            # 파일 업로드 처리
            upload_message = ''
            if params[:course][:content_files].present?
              upload_result = process_file_upload(@course, params[:course])
              if upload_result[:success]
                upload_message = " #{upload_result[:message]}"
              else
                raise ActiveRecord::Rollback, upload_result[:message]
              end
            end
            
            # localStorage 임시저장 데이터 삭제 안내
            flash[:notice] = "✅ 코스가 생성되었습니다.#{upload_message} 임시저장 데이터를 삭제하세요."
            redirect_to admin_course_path(@course)
          else
            @authors = Author.active.order(:name)
            flash.now[:alert] = "⚠️ 입력 내용을 확인해주세요: #{@course.errors.full_messages.join(', ')}"
            render :new, status: :unprocessable_entity
          end
        end
      rescue => e
        @authors = Author.active.order(:name)
        flash.now[:alert] = "❌ 오류가 발생했습니다: #{e.message}"
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @content_status = get_content_status(@course)
      @existing_files = get_existing_files(@course)
    end

    def edit
      @authors = Author.active.order(:name)
      @content_status = get_content_status(@course)
      @existing_files = get_existing_files(@course)
    end

    def update
      begin
        ActiveRecord::Base.transaction do
          if @course.update(course_params)
            # 작가 정보 업데이트
            attach_authors(@course, params[:course])
            
            flash[:notice] = '✅ 코스가 업데이트되었습니다.'
            redirect_to admin_course_path(@course)
          else
            @authors = Author.active.order(:name)
            @content_status = get_content_status(@course)
            flash.now[:alert] = "⚠️ 입력 내용을 확인해주세요: #{@course.errors.full_messages.join(', ')}"
            render :edit, status: :unprocessable_entity
          end
        end
      rescue => e
        @authors = Author.active.order(:name)
        @content_status = get_content_status(@course)
        flash.now[:alert] = "❌ 오류가 발생했습니다: #{e.message}"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy
      redirect_to admin_courses_path, notice: '코스가 삭제되었습니다.'
    end

    def upload_files
      content_type = params[:content_type]
      files = params[:files]

      unless files.present?
        render json: { 
          success: false, 
          errors: ['파일이 선택되지 않았습니다']
        }, status: :unprocessable_entity
        return
      end

      begin
        uploader = ContentFileUploader.new(
          course: @course,
          content_type: content_type,
          files: files
        )

        result = uploader.upload

        if result[:success]
          # 코스의 video_url 또는 ebook_pages_root 자동 업데이트
          update_course_paths(@course, content_type)
          
          render json: { 
            success: true, 
            message: "✅ #{result[:uploaded].count}개 파일 업로드 완료",
            uploaded: result[:uploaded],
            errors: result[:errors]
          }
        else
          render json: { 
            success: false, 
            errors: result[:errors]
          }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "파일 업로드 오류: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { 
          success: false, 
          errors: ["업로드 중 오류가 발생했습니다: #{e.message}"]
        }, status: :internal_server_error
      end
    end

    def delete_file
      file_path = params[:file_path]
      
      # 보안: public 디렉토리 외부 파일 삭제 방지
      unless file_path.start_with?('/ebooks/') || file_path.start_with?('/videos/')
        render json: { success: false, error: '잘못된 파일 경로입니다.' }, status: :forbidden
        return
      end
      
      full_path = Rails.root.join('public', file_path)

      if File.exist?(full_path)
        begin
          File.delete(full_path)
          render json: { success: true, message: '✅ 파일이 삭제되었습니다.' }
        rescue => e
          Rails.logger.error "파일 삭제 오류: #{e.message}"
          render json: { success: false, error: "파일 삭제 중 오류가 발생했습니다: #{e.message}" }, status: :internal_server_error
        end
      else
        render json: { success: false, error: '❌ 파일을 찾을 수 없습니다.' }, status: :not_found
      end
    end

    private
    
    def determine_status(course, page_count, has_video)
      if course.category.to_s.match?(/전자동화책|ebook|동화책/)
        page_count >= 10 ? 'complete' : (page_count > 0 ? 'partial' : 'missing')
      elsif course.category.to_s.match?(/구연동화|storytelling|영상/)
        has_video ? 'complete' : 'missing'
      else
        'unknown'
      end
    end

    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(
        :title, :subtitle, :description, :price, :discount_percentage,
        :category, :level, :duration, :thumbnail, :status, :age,
        :video_url, :ebook_pages_root, :difficulty,
        :series_name, :series_order, :production_date, :tags
      )
    end

    def attach_authors(course, course_params)
      # 기존 작가 연결 제거
      course.course_authors.destroy_all

      # 작가 추가
      if course_params[:writer_id].present?
        course.course_authors.create(
          author_id: course_params[:writer_id],
          role: 'writer',
          order: 1
        )
      end

      # 일러스트레이터 추가
      if course_params[:illustrator_id].present?
        course.course_authors.create(
          author_id: course_params[:illustrator_id],
          role: 'illustrator',
          order: 2
        )
      end

      # 성우 추가
      if course_params[:narrator_id].present?
        course.course_authors.create(
          author_id: course_params[:narrator_id],
          role: 'narrator',
          order: 3
        )
      end
    end

    def process_file_upload(course, course_params)
      content_type = determine_content_type(course)
      files = course_params[:content_files]

      uploader = ContentFileUploader.new(
        course: course,
        content_type: content_type,
        files: files
      )

      result = uploader.upload
      
      {
        success: result[:success],
        message: result[:success] ? "#{result[:uploaded].count}개 파일 업로드됨" : result[:errors].join(', ')
      }
    end

    def determine_content_type(course)
      if course.category.to_s.match?(/전자동화책|ebook|동화책/)
        'ebook_images'
      elsif course.category.to_s.match?(/구연동화|storytelling|영상/)
        'video'
      else
        'ebook_images'
      end
    end

    def get_content_status(course)
      pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
      video_dir = Rails.root.join('public', 'videos', course.id.to_s)
      
      page_images = Dir.glob(pages_dir.join('page_*.{jpg,png}')).sort
      page_captions = Dir.glob(pages_dir.join('page_*.txt')).sort
      has_video = File.exist?(video_dir.join('index.m3u8')) || 
                  File.exist?(video_dir.join('main.mp4'))
      
      {
        page_count: page_images.count,
        caption_count: page_captions.count,
        has_video: has_video,
        status: determine_status(course, page_images.count, has_video)
      }
    end

    def update_course_paths(course, content_type)
      case content_type
      when 'ebook_images', 'captions'
        course.update_column(:ebook_pages_root, "/ebooks/#{course.id}/pages") unless course.ebook_pages_root.present?
      when 'video', 'hls'
        # HLS가 있으면 .m3u8, 없으면 .mp4
        video_dir = Rails.root.join('public', 'videos', course.id.to_s)
        if File.exist?(video_dir.join('index.m3u8'))
          course.update_column(:video_url, "/videos/#{course.id}/index.m3u8")
        elsif File.exist?(video_dir.join('main.mp4'))
          course.update_column(:video_url, "/videos/#{course.id}/main.mp4")
        end
      end
    end
    
    def get_existing_files(course)
      files = {
        images: [],
        captions: [],
        videos: [],
        subtitles: []
      }

      # 이미지 파일
      pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
      if Dir.exist?(pages_dir)
        files[:images] = Dir.glob(pages_dir.join('page_*.{jpg,png}')).map do |f|
          {
            name: File.basename(f),
            path: f.sub(Rails.root.join('public').to_s, ''),
            size: File.size(f)
          }
        end.sort_by { |f| f[:name] }

        files[:captions] = Dir.glob(pages_dir.join('page_*.txt')).map do |f|
          {
            name: File.basename(f),
            path: f.sub(Rails.root.join('public').to_s, ''),
            size: File.size(f)
          }
        end.sort_by { |f| f[:name] }
      end

      # 비디오 파일
      video_dir = Rails.root.join('public', 'videos', course.id.to_s)
      if Dir.exist?(video_dir)
        files[:videos] = Dir.glob(video_dir.join('*.{mp4,webm,m3u8}')).map do |f|
          {
            name: File.basename(f),
            path: f.sub(Rails.root.join('public').to_s, ''),
            size: File.size(f)
          }
        end

        files[:subtitles] = Dir.glob(video_dir.join('*.{vtt,srt}')).map do |f|
          {
            name: File.basename(f),
            path: f.sub(Rails.root.join('public').to_s, ''),
            size: File.size(f)
          }
        end
      end

      files
    end
  end
end
