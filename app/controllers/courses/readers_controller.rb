class Courses::ReadersController < ApplicationController
  before_action :set_course
  before_action :require_login

  def show
    configured_root = @course.respond_to?(:ebook_pages_root) && @course.ebook_pages_root.present? ? @course.ebook_pages_root : "/ebooks/#{@course.id}/pages"
    relative_root = configured_root.sub(%r{^/}, "")
    public_root = Rails.root.join("public")

    # jpg/png 모두 탐색 (001부터 가정하되 파일명 정렬로 순서 보장)
    glob_pattern = File.join(public_root.to_s, relative_root, "page_*.{jpg,png}")
    @page_files = Dir.glob(glob_pattern).sort
    @total_pages = @page_files.size

    if @total_pages.zero?
      @use_placeholder = true
      @total_pages = 1
    end

    @is_enrolled = current_user&.admin? || current_user&.enrolled_courses&.include?(@course)
    # 프리뷰 한도: 총 페이지의 10%를 기준으로 하되, 펼침형(양면) UX를 위해 최소 한 spread(오른쪽 3p)까지 허용
    raw_limit = (@total_pages * 0.1).ceil
    normalized = [raw_limit, 3].max
    normalized += 1 if normalized.even? # 오른쪽 페이지(홀수)로 정렬
    @preview_last_page = [normalized, @total_pages].min
    @pages_root = "/#{relative_root}"
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end
end


