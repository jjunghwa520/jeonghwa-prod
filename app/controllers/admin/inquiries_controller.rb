class Admin::InquiriesController < Admin::BaseController
  before_action :set_inquiry, only: [:show, :update]
  
  def index
    @pending_inquiries = Inquiry.pending.recent
    @answered_inquiries = Inquiry.answered.recent.limit(10)
  end
  
  def show
  end
  
  def update
    if @inquiry.update(inquiry_params)
      @inquiry.update(status: 'answered') if params[:inquiry][:admin_response].present?
      flash[:success] = '답변이 등록되었습니다.'
      redirect_to admin_inquiries_path
    else
      flash[:error] = @inquiry.errors.full_messages.join(', ')
      render :show
    end
  end
  
  private
  
  def set_inquiry
    @inquiry = Inquiry.find(params[:id])
  end
  
  def inquiry_params
    params.require(:inquiry).permit(:admin_response, :status)
  end
end

