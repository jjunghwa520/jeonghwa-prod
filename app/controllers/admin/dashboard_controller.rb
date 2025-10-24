module Admin
  class DashboardController < BaseController
    def index
      @courses_count = Course.count
      @users_count = User.count
      @reviews_count = Review.count
      @enrollments_count = Enrollment.count
      
      # 콘텐츠 상태 분석
      @content_stats = analyze_content_status
      
      # 최근 활동
      @recent_enrollments = Enrollment.includes(:user, :course).order(created_at: :desc).limit(5)
      @recent_reviews = Review.includes(:user, :course).order(created_at: :desc).limit(5)
      
      # 인기 코스 (수강생 많은 순)
      @popular_courses = Course.joins(:enrollments)
                               .group('courses.id')
                               .select('courses.*, COUNT(enrollments.id) as enrollment_count')
                               .order('enrollment_count DESC')
                               .limit(5)
    end
    
    private
    
    def analyze_content_status
      ebook_courses = Course.where(category: ['전자동화책', 'ebook', '동화책'])
      video_courses = Course.where(category: ['구연동화', 'storytelling', '영상'])
      
      ebook_with_pages = 0
      ebook_complete = 0
      video_with_content = 0
      
      ebook_courses.each do |course|
        pages_dir = Rails.root.join('public', 'ebooks', course.id.to_s, 'pages')
        page_count = Dir.glob(pages_dir.join('page_*.{jpg,png}')).count
        
        ebook_with_pages += 1 if page_count > 0
        ebook_complete += 1 if page_count >= 10
      end
      
      video_courses.each do |course|
        video_dir = Rails.root.join('public', 'videos', course.id.to_s)
        has_video = File.exist?(video_dir.join('index.m3u8')) || 
                    File.exist?(video_dir.join('main.mp4'))
        video_with_content += 1 if has_video
      end
      
      {
        ebook_total: ebook_courses.count,
        ebook_complete: ebook_complete,
        ebook_partial: ebook_with_pages - ebook_complete,
        ebook_missing: ebook_courses.count - ebook_with_pages,
        video_total: video_courses.count,
        video_complete: video_with_content,
        video_missing: video_courses.count - video_with_content
      }
    end
  end
end


