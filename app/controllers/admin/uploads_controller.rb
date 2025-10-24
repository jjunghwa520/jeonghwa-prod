require 'fileutils'

module Admin
  class UploadsController < BaseController
    def new
    end

    def create
      course_id = params[:course_id].presence || params.dig(:upload, :course_id)
      kind = params[:kind].presence || params.dig(:upload, :kind)
      files = params[:files] || params.dig(:upload, :files)

      unless course_id.present? && kind.present? && files.present?
        redirect_to new_admin_upload_path, alert: 'course_id, kind, files가 필요합니다.' and return
      end

      base = Rails.root.join('public')
      dest_dir = case kind
                 when 'ebook_images' then base.join('ebooks', course_id.to_s, 'pages')
                 when 'captions' then base.join('ebooks', course_id.to_s, 'pages')
                 when 'video' then base.join('videos', course_id.to_s)
                 when 'subtitle' then base.join('videos', course_id.to_s)
                 when 'hls' then base.join('videos', course_id.to_s)
                 else nil
                 end
      unless dest_dir
        redirect_to new_admin_upload_path, alert: '지원하지 않는 kind 입니다.' and return
      end

      FileUtils.mkdir_p(dest_dir)
      saved = []
      Array(files).each do |f|
        fname = f.original_filename
        path = dest_dir.join(fname)
        File.open(path, 'wb'){|io| io.write(f.read)}
        saved << path.to_s.sub(Rails.root.join('public').to_s, '')
      end

      redirect_to new_admin_upload_path, notice: "업로드 완료: #{saved.join(', ')}"
    end
  end
end


