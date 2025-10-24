module Admin
  class AuthorsController < BaseController
    before_action :set_author, only: [:edit, :update, :destroy]

    def index
      @authors = Author.order(name: :asc)
    end

    def new
      @author = Author.new
    end

    def create
      @author = Author.new(author_params)
      
      respond_to do |format|
        if @author.save
          format.html { redirect_to admin_authors_path, notice: '작가가 등록되었습니다.' }
          format.json { render json: { id: @author.id, name: @author.name, role: @author.role }, status: :created }
        else
          format.html { render :new }
          format.json { render json: { errors: @author.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      if @author.update(author_params)
        redirect_to admin_authors_path, notice: '작가 정보가 업데이트되었습니다.'
      else
        render :edit
      end
    end

    def destroy
      @author.destroy
      redirect_to admin_authors_path, notice: '작가가 삭제되었습니다.'
    end

    private

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :bio, :profile_image, :role, :active)
    end
  end
end
