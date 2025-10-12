class GeneratedImagesController < ApplicationController
  before_action :require_login
  before_action :set_generated_image, only: [:show, :retry, :destroy]
  
  def index
    @generated_images = current_user.admin? ? GeneratedImage.all : current_user.generated_images
    @generated_images = @generated_images.recent.page(params[:page])
  end
  
  def new
    @generated_image = GeneratedImage.new
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
  
  def create
    @generated_image = GeneratedImage.new(generated_image_params)
    @generated_image.user = current_user
    
    if @generated_image.save
      @generated_image.generate_async!
      redirect_to @generated_image, notice: '이미지 생성이 시작되었습니다. 잠시만 기다려주세요.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: @generated_image }
    end
  end
  
  def retry
    if @generated_image.retry!
      redirect_to @generated_image, notice: '이미지 생성을 다시 시도합니다.'
    else
      redirect_to @generated_image, alert: '현재 처리 중인 작업이 있습니다.'
    end
  end
  
  def destroy
    @generated_image.destroy
    redirect_to generated_images_path, notice: '생성된 이미지가 삭제되었습니다.'
  end
  
  # AJAX를 위한 상태 확인
  def status
    @generated_image = GeneratedImage.find(params[:id])
    render json: {
      status: @generated_image.status,
      image_url: @generated_image.image_url,
      error_message: @generated_image.error_message
    }
  end
  
  private
  
  def set_generated_image
    @generated_image = current_user.admin? ? 
      GeneratedImage.find(params[:id]) : 
      current_user.generated_images.find(params[:id])
  end
  
  def generated_image_params
    params.require(:generated_image).permit(
      :prompt, :image_type, :style, :size, :course_id,
      metadata: [:description, :title, :keywords]
    )
  end
end
