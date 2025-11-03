class InquiriesController < ApplicationController
  before_action :require_login
  before_action :set_inquiry, only: [:show]
  
  def index
    @inquiries = current_user.inquiries.recent
  end
  
  def show
  end
  
  def new
    @inquiry = Inquiry.new
  end
  
  def create
    @inquiry = current_user.inquiries.build(inquiry_params)
    @inquiry.status = 'pending'
    
    if @inquiry.save
      flash[:success] = '문의가 등록되었습니다. 빠른 시일 내에 답변드리겠습니다.'
      redirect_to inquiries_path
    else
      flash[:error] = @inquiry.errors.full_messages.join(', ')
      render :new
    end
  end
  
  private
  
  def set_inquiry
    @inquiry = current_user.inquiries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = '문의를 찾을 수 없습니다.'
    redirect_to inquiries_path
  end
  
  def inquiry_params
    params.require(:inquiry).permit(:title, :content)
  end
  
  def require_login
    unless current_user
      flash[:error] = '로그인이 필요합니다.'
      redirect_to login_path
    end
  end
end

