class EventsController < ApplicationController
  def index
    @active_events = Event.active.order(start_date: :desc)
    @upcoming_events = Event.upcoming.order(start_date: :asc)
    @ended_events = Event.ended.order(end_date: :desc).limit(5)
  end
  
  def show
    @event = Event.find(params[:id])
    @related_courses = Course.all.limit(6)  # 이벤트에 연결된 콘텐츠
  end
end

