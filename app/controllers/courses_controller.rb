class CoursesController < ApplicationController
  before_action :set_course, only: [ :show, :edit, :update, :destroy, :enroll, :watch ]
  before_action :require_login, except: [ :index, :show, :search ]
  before_action :require_instructor, only: [ :new, :create ]
  before_action :require_course_owner, only: [ :edit, :update, :destroy ]

  def index
    @courses = Course.published.includes(:instructor, :reviews)
    
    # 카테고리 필터링 (기존 + 청소년 전용 카테고리)
    if params[:category].present?
      case params[:category]
      when 'ebook'
        @courses = @courses.where(category: ['전자동화책', 'ebook', '동화책'])
        @page_title = "📖 전자동화책"
        @page_description = "터치하고 듣고 읽는 인터랙티브 동화책"
      when 'storytelling'
        @courses = @courses.where(category: ['구연동화', 'storytelling', '영상'])
        @page_title = "🎭 구연동화 영상"
        @page_description = "전문 성우가 들려주는 생생한 구연동화"
      when 'education'
        @courses = @courses.where(category: ['동화만들기', 'education', '교육'])
        @page_title = "✍️ 동화만들기 교육"
        @page_description = "나만의 동화책을 만드는 창작 교육"
      # 청소년 전용 카테고리들 (2개로 단순화)
      when 'teen_content'
        # 엔터테인먼트 카테고리 (원래 카테고리 기준으로 필터링)
        entertainment_categories = ['웹툰', '라이트노벨', '댄스', '크리에이터']
        @courses = @courses.where(category: entertainment_categories)
        
        # 세부 카테고리 필터링
        if params[:subcategory].present?
          case params[:subcategory]
          when 'webtoon'
            @courses = @courses.where(category: '웹툰')
            @page_title = "📱 만화 & 웹툰"
            @page_description = "웹툰 스토리텔링과 디지털 드로잉을 배워보세요"
          when 'animation'
            # 애니메이션 관련 카테고리가 없으므로 크리에이터로 매핑
            @courses = @courses.where(category: '크리에이터')
            @page_title = "🎬 애니메이션 & 영상"
            @page_description = "영상 제작과 애니메이션 콘텐츠 크리에이터 되기"
          when 'novel'
            @courses = @courses.where(category: '라이트노벨')
            @page_title = "📚 라이트노벨 & 소설"
            @page_description = "청소년을 위한 라이트노벨 창작 과정"
          when 'dance'
            @courses = @courses.where(category: '댄스')
            @page_title = "🎵 K-POP & 댄스"
            @page_description = "K-POP 댄스와 안무 창작을 배워보세요"
          end
        else
          @page_title = "📱 청소년 콘텐츠"
          @page_description = "만화, 애니메이션, 웹툰, 라이트노벨 등 청소년이 즐기는 엔터테인먼트 콘텐츠"
        end
        
      when 'teen_education'
        # 교육 카테고리 (원래 카테고리 기준으로 필터링)
        education_categories = ['게임', '진로', '자기계발', '크리에이터']
        @courses = @courses.where(category: education_categories)
        
        # 세부 카테고리 필터링
        if params[:subcategory].present?
          case params[:subcategory]
          when 'creative'
            # 창작 & 디자인은 웹툰 카테고리로 매핑 (창작 관련)
            @courses = @courses.where(category: ['웹툰'])
            @page_title = "🎨 창작 & 디자인"
            @page_description = "웹툰, 일러스트 등 창작과 디자인을 배워보세요"
          when 'game'
            @courses = @courses.where(category: '게임')
            @page_title = "🎮 게임 개발 & 코딩"
            @page_description = "게임 기획부터 코딩까지, 게임 개발의 모든 것"
          when 'career'
            @courses = @courses.where(category: ['진로', '자기계발'])
            @page_title = "🌟 진로 탐색 & 자기계발"
            @page_description = "나의 꿈과 적성을 찾고 성장하는 진로 탐색 과정"
          when 'creator'
            @courses = @courses.where(category: '크리에이터')
            @page_title = "📸 크리에이터 & 미디어"
            @page_description = "SNS 콘텐츠 제작과 미디어 크리에이터 되기"
          end
        else
          @page_title = "🎓 청소년 교육"
          @page_description = "창작, 게임 개발, 진로 탐색, 크리에이터 등 청소년 성장을 위한 교육 과정"
        end
      end
    else
      @page_title = "🎪 모든 동화 콘텐츠"
      @page_description = "정화의 서재의 모든 동화책 콘텐츠를 만나보세요"
    end
    
    # 연령별 필터링
    if params[:age].present?
      @courses = @courses.by_age(params[:age])
      case params[:age]
      when 'baby'
        @page_title = "👶 0-3세 영유아 콘텐츠"
        @page_description = "영유아를 위한 단순하고 따뜻한 동화"
      when 'toddler'
        @page_title = "🧒 4-7세 유아 콘텐츠"
        @page_description = "유아의 상상력을 키우는 재미있는 동화"
      when 'elementary'
        @page_title = "👦 8-12세 초등학생 콘텐츠"
        @page_description = "초등학생을 위한 모험과 학습이 있는 동화"
      when 'teen'
        @page_title = "🧑‍🎓 14-16세 청소년 콘텐츠"
        @page_description = "청소년을 위한 만화/애니메이션 스타일 콘텐츠"
      end
    end
    
    @courses = @courses.limit(20)
    @current_category = params[:category]
    @current_age = params[:age]
  end

  def show
    @review = Review.new
    @reviews = @course.reviews.recent.includes(:user)
    @is_enrolled = current_user&.enrolled_courses&.include?(@course)
    @in_cart = current_user&.cart_items&.exists?(course: @course)
  end

  def new
    @course = current_user.taught_courses.build
  end

  def create
    @course = current_user.taught_courses.build(course_params)

    if @course.save
      flash[:notice] = "강의가 성공적으로 생성되었습니다."
      redirect_to @course
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      flash[:notice] = "강의가 업데이트되었습니다."
      redirect_to @course
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    flash[:notice] = "강의가 삭제되었습니다."
    redirect_to courses_path
  end

  def search
    @query = params[:q]
    @courses = Course.published

    if @query.present?
      @courses = @courses.search(@query)
    end

    @courses = @courses.by_category(params[:category]) if params[:category].present?
    @courses = @courses.by_level(params[:level]) if params[:level].present?
    @courses = @courses.by_age(params[:age]) if params[:age].present?
    @courses = @courses.includes(:instructor, :reviews).limit(20)

    @categories = Course.published.distinct.pluck(:category).compact
    @levels = %w[beginner intermediate advanced]
    @ages = %w[baby toddler elementary teen]
  end

  def enroll
    if current_user.enrolled_courses.include?(@course)
      flash[:alert] = "이미 수강 중인 강의입니다."
    else
      current_user.enrollments.create(course: @course)
      flash[:notice] = "강의 수강이 시작되었습니다!"
    end
    redirect_to @course
  end

  def watch
    @enrollment = current_user.enrollments.find_by(course: @course)
    unless @enrollment
      flash[:alert] = "수강 신청이 필요합니다."
      redirect_to @course
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :price, :category, :level, :duration, :thumbnail, :status, :age)
  end

  def require_course_owner
    unless @course.instructor == current_user || current_user&.admin?
      flash[:alert] = "접근 권한이 없습니다."
      redirect_to @course
    end
  end
end
