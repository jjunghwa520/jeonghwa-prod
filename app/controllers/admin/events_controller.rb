class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  
  def index
    @events = Event.order(created_at: :desc)
  end
  
  def show
  end
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(event_params)
    
    if @event.save
      flash[:success] = '이벤트가 생성되었습니다.'
      redirect_to admin_events_path
    else
      flash.now[:error] = @event.errors.full_messages.join(', ')
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @event.update(event_params)
      flash[:success] = '이벤트가 수정되었습니다.'
      redirect_to admin_event_path(@event)
    else
      flash.now[:error] = @event.errors.full_messages.join(', ')
      render :edit
    end
  end
  
  def destroy
    @event.destroy
    flash[:success] = '이벤트가 삭제되었습니다.'
    redirect_to admin_events_path
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(:title, :description, :start_date, :end_date, :discount_rate, :status, :event_type, :banner_image)
  end
end

